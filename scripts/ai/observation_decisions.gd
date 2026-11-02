class_name ObservationDecisions
extends RefCounted
## Value-only state machine: private memory snapshots, own position and execution feedback.

enum State { EXPLORE, OBSERVE, INVESTIGATE, RESUME }
var state: State = State.EXPLORE
var teammate_ids: Array[StringName] = []
var interval_ticks: int = 15
var freshness_ticks: int = 300
var minimum_observe_ticks: int = 45
var maximum_observe_ticks: int = 90
var investigation_timeout_ticks: int = 240
var cooldown_ticks: int = 180
var subject_cooldown_ticks: int = 900
var maximum_distance: float = 12.0
var revisit_distance: float = 3.0
var evidence: Dictionary = {}
var coordination: ReportCoordination
var investigation_destination := Vector3.ZERO
var evaluations: int = 0
var inspected_facts: int = 0
var transitions: int = 0
var _next_tick: int = 0
var _until: int = 0
var _eligible_at: int = 0
var _handled: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()


func initialize(seed_value: int) -> void:
	_rng.seed = seed_value
	if coordination != null:
		coordination.initialize(seed_value)
	investigation_destination = Vector3.ZERO
	state = State.EXPLORE
	evidence = {}
	_handled.clear()
	_next_tick = 0
	_until = 0
	_eligible_at = 0
	evaluations = 0
	inspected_facts = 0
	transitions = 0


func step(now: int, facts: Dictionary, own_position: Vector3,
		arrived: bool = false, failed: bool = false) -> void:
	if now < _next_tick:
		return
	_next_tick = now + maxi(1, interval_ticks)
	evaluations += 1
	match state:
		State.EXPLORE:
			if now < _eligible_at:
				return
			var candidate := _choose(facts, own_position, now)
			if candidate.is_empty():
				return
			evidence = candidate.duplicate(true)
			investigation_destination = evidence.position
			_remember_handled(now)
			_until = now + _rng.randi_range(minimum_observe_ticks, maxi(minimum_observe_ticks, maximum_observe_ticks))
			if coordination != null and evidence.source == &"team_report":
				investigation_destination = coordination.selected.destination
				_until += int(coordination.selected.delay_ticks)
			_change(State.OBSERVE)
		State.OBSERVE:
			if not _fresh(evidence, now):
				_resume(now, "Original evidence expired")
			elif now >= _until:
				# Still actually seen in this sampling phase? Observe, then move on;
				# do not chase a visible actor or keep extending the observation pause.
				var latest: Dictionary = facts.get(evidence.subject, {})
				if latest.get("source") == &"vision" and latest.get("tick", -1) == now:
					_resume(now, "Subject actually observed locally; no report pursuit")
				elif coordination != null and evidence.source == &"team_report" \
						and coordination.selected.action == "Pause nearby":
					_resume(now, "Nearby observation pause completed")
				else:
					_until = now + investigation_timeout_ticks
					_change(State.INVESTIGATE)
		State.INVESTIGATE:
			# Evidence is pinned for this entire visit, even if newer reports arrive.
			if arrived or failed or now >= _until or not _fresh(evidence, now):
				var reason := "Area visit completed"
				if not _fresh(evidence, now):
					reason = "Original evidence expired"
				elif failed:
					reason = "Path unavailable or blocked beyond retries"
				elif not arrived:
					reason = "Investigation time limit reached"
				_resume(now, reason)
		State.RESUME:
			if now >= _until:
				evidence = {}
				_change(State.EXPLORE)


func _fresh(fact: Dictionary, now: int) -> bool:
	var tick: int = fact.get("tick", -1)
	return tick >= 0 and tick <= now and now - tick < freshness_ticks


func _choose(facts: Dictionary, own_position: Vector3, now: int) -> Dictionary:
	var best: Dictionary = {}
	var best_plan: Dictionary = {}
	if coordination != null:
		coordination.begin_evaluation()
	var count := 0
	for subject in facts:
		if count >= 8:
			break
		count += 1
		inspected_facts += 1
		var fact: Dictionary = facts[subject]
		if subject in teammate_ids or not _fresh(fact, now):
			continue
		if fact.source not in [&"vision", &"team_report"] or fact.event != &"seen":
			continue
		if own_position.distance_to(fact.position) > maximum_distance:
			if coordination != null and fact.source == &"team_report":
				coordination.note(fact, "Continue exploration", "Reported area is too distant")
			continue
		var eligible := true
		for handled in _handled:
			if handled.subject == subject:
				# A newer tick alone never justifies another visit to the same place.
				eligible = eligible and now >= handled.until and fact.tick > handled.tick \
					and fact.position.distance_to(handled.position) >= revisit_distance
			if now < handled.until and fact.position.distance_to(handled.position) < revisit_distance:
				eligible = false
		if not eligible:
			if coordination != null and fact.source == &"team_report":
				coordination.note(fact, "Continue exploration", "Subject or location already handled/cooling down")
			continue
		var plan: Dictionary = {}
		if coordination != null and fact.source == &"team_report":
			plan = coordination.assess(fact, own_position, now, freshness_ticks, maxi(minimum_observe_ticks, maximum_observe_ticks), maximum_distance)
			if not plan.accepted:
				continue
		var prefer_local: bool = coordination != null and not best.is_empty() and fact.source != best.source
		var replace: bool = best.is_empty() or fact.tick > best.tick or (fact.tick == best.tick \
			and own_position.distance_to(fact.position) < own_position.distance_to(best.position))
		if prefer_local:
			replace = fact.source == &"vision"
		if replace:
			best = fact
			best_plan = plan
	if coordination != null:
		coordination.commit(best, best_plan)
	return best


func _remember_handled(now: int) -> void:
	for index in range(_handled.size() - 1, -1, -1):
		if _handled[index].subject == evidence.subject:
			_handled.remove_at(index)
	if _handled.size() >= 8:
		_handled.pop_front()
	_handled.append({"subject": evidence.subject, "tick": evidence.tick,
		"position": evidence.position, "until": now + subject_cooldown_ticks})


func _resume(now: int, reason: String = "Response ended") -> void:
	if coordination != null and evidence.get("source") == &"team_report":
		coordination.finish(reason)
	_until = now + _rng.randi_range(30, 45)
	_eligible_at = now + cooldown_ticks + _rng.randi_range(0, 30)
	_change(State.RESUME)


func _change(next: State) -> void:
	state = next
	transitions += 1
