class_name ReportCoordination
extends RefCounted
## Local assessment of delivered snapshots. No world registry or shared planner state.

var maximum_report_age_ticks: int = 120
var area_radius: float = 1.5
var nearby_distance: float = 2.5
var reserve_ticks: int = 30
var move_speed: float = 4.0
var ticks_per_second: int = 60
var assessments: int = 0
var selected: Dictionary = {}
var _evidence: Dictionary = {}
var _decision: String = "No delivered report"
var _reason: String = "Continue independent exploration"
var _profile: int = 0


func initialize(seed_value: int) -> void:
	_profile = posmod(seed_value, 3)
	assessments = 0
	begin_evaluation()


func begin_evaluation() -> void:
	selected = {}
	_evidence = {}
	_decision = "No relevant report"
	_reason = "Continue independent exploration"


func assess(fact: Dictionary, own_position: Vector3, now: int,
		freshness_ticks: int, observe_budget_ticks: int, maximum_distance: float) -> Dictionary:
	assessments += 1
	var age: int = now - int(fact.tick)
	var plan := {"accepted": false, "action": "Continue exploration", "destination": fact.position,
		"delay_ticks": 15 * (1 + _profile), "reason": "Report is too old or future-dated"}
	if fact.source == &"team_report" and age >= 0 and age < mini(freshness_ticks, maximum_report_age_ticks):
		var distance := own_position.distance_to(fact.position)
		plan.reason = "Reported area is too distant"
		if distance <= maximum_distance:
			plan.action = "Pause nearby" if distance <= nearby_distance else "Check area"
			var angle := TAU * float(_profile) / 3.0
			plan.destination = fact.position + Vector3(cos(angle), 0, sin(angle)) * area_radius
			var travel := own_position.distance_to(plan.destination) if plan.action == "Check area" else 0.0
			var estimate := ceili(travel / maxf(0.1, move_speed) * ticks_per_second)
			plan.accepted = age + estimate + observe_budget_ticks + int(plan.delay_ticks) + reserve_ticks < freshness_ticks
			plan.reason = "Fresh last-seen area only; occupancy unconfirmed" if plan.accepted \
				else "Insufficient evidence lifetime for pause and estimated travel"
	if fact.source != &"team_report":
		plan.reason = "Not a delivered team report"
	if not plan.accepted:
		plan.action = "Continue exploration"
	note(fact, plan.action, plan.reason)
	return plan


func note(fact: Dictionary, decision: String, reason: String) -> void:
	# Diagnostic explanation of this local evaluation, not another actionable memory.
	if _evidence.is_empty() or fact.tick >= _evidence.tick:
		_evidence = fact.duplicate(true)
		_decision = decision
		_reason = reason


func commit(fact: Dictionary, plan: Dictionary) -> void:
	if fact.is_empty():
		return
	if fact.source != &"team_report":
		begin_evaluation()
		_decision = "Local observation"
		_reason = "Eligible direct evidence takes priority"
		return
	selected = plan.duplicate(true)
	_evidence = fact.duplicate(true)
	_decision = selected.action
	_reason = selected.reason


func finish(reason: String) -> void:
	_decision = "Resume exploration"
	_reason = reason


func travel_limit(now: int, freshness_ticks: int, timeout_ticks: int) -> float:
	var remaining := mini(freshness_ticks - (now - int(_evidence.tick)), timeout_ticks) - reserve_ticks
	return maxf(0.0, float(remaining) / ticks_per_second * move_speed)


func inspect(now: int, freshness_ticks: int) -> Dictionary:
	var age: int = -1 if _evidence.is_empty() else now - int(_evidence.tick)
	var expired: bool = age < 0 or age >= freshness_ticks
	return {"decision": _decision, "reason": _reason,
		"reporter": "" if _evidence.is_empty() else String(_evidence.observer),
		"age_ticks": age, "uncertain": not _evidence.is_empty(), "expired": expired,
		"reported_position": null if expired else _evidence.position,
		"approach": null if expired or selected.is_empty() else selected.destination}
