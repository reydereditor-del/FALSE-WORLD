class_name AIDebugState
extends RefCounted
## Read-only diagnostics. No perception queries, world registry or target transforms.

const STATES := ["Explore", "Observe", "Investigate", "Resume"]


static func read(controller: ObservationController, now: int) -> Dictionary:
	var memory := controller.memory
	var evidence := controller.decisions.evidence
	var direct: Dictionary = {}
	var own_id := StringName(controller.motor.name)
	for fact: Dictionary in memory.inspect(now).values():
		if fact.source == &"vision" and fact.observer == own_id:
			if direct.is_empty() or fact.tick > direct.tick:
				direct = fact
	# A selected local snapshot can survive replacement by a newer reported fact.
	if not evidence.is_empty() and evidence.source == &"vision" and evidence.observer == own_id:
		if evidence.tick <= now and now - evidence.tick < memory.freshness_ticks:
			if direct.is_empty() or evidence.tick > direct.tick:
				direct = evidence
	var selected_source := "None"
	var selected_age := -1
	var selected_position: Variant = null
	var selected_expired := false
	if not evidence.is_empty():
		selected_source = "Direct vision" if evidence.source == &"vision" else "Delayed team report"
		selected_age = now - int(evidence.tick)
		selected_expired = selected_age < 0 or selected_age >= memory.freshness_ticks
		if not selected_expired:
			selected_position = evidence.position
	var navigation := "Moving"
	if controller.waiting or not controller._started:
		navigation = "Waiting"
	elif controller.repath_attempts > 0:
		navigation = "Recovering"
	elif controller._stalled_ticks > 0:
		navigation = "Blocked"
	var last_sample_tick := controller._next_plan_tick - maxi(1, controller.update_interval_ticks)
	var direct_at_latest_sample: bool = not direct.is_empty() and direct.tick == last_sample_tick \
		and now >= last_sample_tick and now - last_sample_tick < controller.update_interval_ticks
	return {"id": String(own_id), "state": STATES[controller.decisions.state],
		"destination": controller._goal if controller._started else null,
		"navigation": navigation, "retries": controller.repath_attempts,
		"direct_position": null if direct.is_empty() else direct.position,
		"direct_subject": "" if direct.is_empty() else String(direct.subject),
		"direct_age_ticks": -1 if direct.is_empty() else now - int(direct.tick),
		"direct_at_latest_sample": direct_at_latest_sample,
		"selected_source": selected_source, "selected_age_ticks": selected_age,
		"selected_expired": selected_expired, "selected_position": selected_position}


static func describe(view: Dictionary, ticks_per_second: int) -> String:
	var direct := "none available"
	if view.direct_position != null:
		var label := "latest sample" if view.direct_at_latest_sample else "last-seen memory"
		direct = "%s %s; %.2fs; %s" % [view.direct_subject, point(view.direct_position),
			float(view.direct_age_ticks) / ticks_per_second, label]
	var selected: String = view.selected_source
	if view.selected_age_ticks >= 0:
		selected += "; %.2fs" % (float(view.selected_age_ticks) / ticks_per_second)
	if view.selected_expired:
		selected += "; expired"
	elif view.selected_position != null:
		selected += "; " + point(view.selected_position)
	var nav_label := "Nav destination (retained/inactive)" if view.navigation == "Waiting" else "Nav destination"
	return "%s | %s | %s (retries %d)\n%s: %s\nLast direct: %s\nSelected evidence: %s" % [
		view.id, view.state, view.navigation, view.retries, nav_label, point(view.destination), direct, selected]


static func point(position: Variant) -> String:
	if position == null:
		return "none"
	return "(%.1f, %.1f, %.1f)" % [position.x, position.y, position.z]
