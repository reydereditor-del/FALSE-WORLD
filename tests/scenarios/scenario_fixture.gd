extends RefCounted
## Privileged test fixture only. No production script references this module.

const WORLD := preload("res://scenes/prototype/stage3c_coordination.tscn")
const IDS: Array[StringName] = [&"K72", &"B14", &"D09"]
const STATES := ["Explore", "Observe", "Investigate", "Resume"]
var tree: SceneTree
var world: Node3D
var human: CharacterMotor
var controllers: Array = []
var sensors: Array = []
var channels: Array[ObservedFactChannel] = []
var sample_enabled := [true, false, false]
var plan_enabled := [true, false, false]
var now: int = 0
var frames_used: int = 0
var audits: int = 0
var checks: int = 0
var failures: Array[String] = []
var trace: Array[Dictionary] = []
var semantics: Array = []
var ledger: Dictionary = {}
var routes: Dictionary = {}
var _remembered: Dictionary = {}
var _committed: Dictionary = {}
var _started_ms: int = 0
var _observations: int = 0
var _state_events: int = 0
var _aborted: bool = false


func setup(scene_tree: SceneTree, seed_value: int) -> void:
	tree = scene_tree
	_started_ms = Time.get_ticks_msec()
	world = WORLD.instantiate()
	world.simulation_seed = seed_value
	tree.root.add_child(world)
	world.set_physics_process(false)
	human = world.get_node("Character")
	human.get_node("LocalController").set_physics_process(false)
	human.get_node("LocalController").set_process_unhandled_input(false)
	controllers.assign(world.controllers)
	sensors.assign(world.sensors)
	for index in range(3):
		var controller: ObservationController = controllers[index]
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
		controller.motor.position = Vector3(35 - index * 5, 0.1, 35)
		controller.motor.velocity = Vector3.ZERO
		controller.initialize()
		sensors[index].candidates = {&"F11": human}
		for connection in sensors[index].observed.get_connections():
			sensors[index].observed.disconnect(connection.callable)
		sensors[index].observed.connect(_observed.bind(index))
	_add_ring()
	place_agent(0, Vector3(0, 0.1, 5), 0.0)
	human.position = Vector3(3, 0.1, 1)
	for frame in range(30):
		await tree.physics_frame
		await tree.process_frame
		if frame >= 2 and NavigationServer3D.map_get_iteration_id(controllers[0].navigator.get_navigation_map()) > 0:
			break
	record("setup", {"seed": seed_value, "map_iteration": NavigationServer3D.map_get_iteration_id(
		controllers[0].navigator.get_navigation_map())})
	expect(NavigationServer3D.map_get_iteration_id(controllers[0].navigator.get_navigation_map()) > 0,
		"navigation map synchronized before decisions")


func _add_ring() -> void:
	var channel := ObservedFactChannel.new()
	for index in range(3):
		channel.register(sensors[index], IDS[(index + 1) % 3], controllers[index].memory)
		routes[String(IDS[index]) + ">" + String(IDS[(index + 1) % 3])] = channel.delay_ticks
	channels.append(channel)


func two_recipients() -> void:
	# Deliberate test topology, not a change to the production one-recipient ring.
	for index in range(3):
		for connection in sensors[index].observed.get_connections():
			sensors[index].observed.disconnect(connection.callable)
		sensors[index].observed.connect(_observed.bind(index))
	channels.clear()
	routes.clear()
	for recipient in [1, 2]:
		var channel := ObservedFactChannel.new()
		channel.register(sensors[0], IDS[recipient], controllers[0].memory)
		channel.register(sensors[recipient], IDS[0], controllers[recipient].memory)
		channels.append(channel)
		routes["K72>" + String(IDS[recipient])] = channel.delay_ticks
		routes[String(IDS[recipient]) + ">K72"] = channel.delay_ticks
	record("topology", {"mode": "two independent single-recipient channels from one real signal"})


func place_agent(index: int, position: Vector3, yaw: float) -> void:
	controllers[index].motor.position = position
	controllers[index].motor.velocity = Vector3.ZERO
	controllers[index].motor.get_node("Visual").rotation.y = yaw
	controllers[index].initialize()
	record("place_agent", {"id": IDS[index], "position": position})


func move_human(position: Vector3) -> void:
	human.position = position
	human.velocity = Vector3.ZERO
	record("human_fixture_move", {"position": position})


func blocker(position: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	world.add_child(body)
	body.position = position
	record("fixture_blocker", {"position": position, "size": size})


func clear_ray(index: int) -> bool:
	var actor: CharacterMotor = controllers[index].motor
	var query := PhysicsRayQueryParameters3D.create(actor.global_position + Vector3.UP * 1.4,
		human.global_position + Vector3.UP * 1.2, 1, [actor.get_rid()])
	var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.collider == human


func step(count: int = 1) -> void:
	for frame in range(count):
		if _aborted:
			return
		if frames_used >= 3600 or Time.get_ticks_msec() - _started_ms > 15000:
			fail("scenario finite frame/wall-time budget exceeded")
			return
		now += 1
		frames_used += 1
		world.simulation_tick = now
		for channel in channels:
			channel.advance(now)
		for index in range(3):
			var controller: ObservationController = controllers[index]
			if (now + controller.schedule_offset) % controller.update_interval_ticks != 0:
				continue
			if sample_enabled[index]:
				sensors[index].sample(now)
			if plan_enabled[index]:
				var before := controller.decisions.state
				var deadline: int = controller.decisions._until
				var queries := controller.path_queries
				var evaluations := controller.decisions.evaluations
				var assessments := controller.decisions.coordination.assessments
				controller.plan(now)
				if controller.path_queries - queries > 2 or controller.decisions.evaluations - evaluations > 1 \
						or controller.decisions.coordination.assessments - assessments > 8:
					fail("per-phase decision/path/assessment budget exceeded")
				var view := AIDebugState.read(controller, now)
				record("decision", {"id": IDS[index], "before": STATES[before], "after": view.state,
					"evidence": controller.decisions.evidence.duplicate(true), "destination": view.destination,
					"reason": _reason(controller, before, deadline), "coordination_reason": view.coordination.reason,
					"assessment": view.coordination.decision,
					"inputs": {"previous_deadline": deadline, "arrived": controller._arrived, "failed": controller._failed},
					"retries": controller.repath_attempts, "path_requests": controller.path_queries})
				if before != controller.decisions.state:
					_state_events += 1
					semantics.append(["state", now, String(IDS[index]), view.state,
						controller.decisions.evidence.get("tick", -1), _point(controller.decisions.investigation_destination)])
		_audit()
		await tree.physics_frame
		await tree.process_frame


func _reason(controller: ObservationController, before: int, deadline: int) -> String:
	# Diagnostics classify an already completed transition; never feed AI decisions.
	var d := controller.decisions
	if before == d.state:
		return "No state transition; existing state/cooldown/committed work retained"
	if d.state == ObservationDecisions.State.OBSERVE:
		return "Accepted delivered private-memory evidence: " + String(d.evidence.source)
	if d.state == ObservationDecisions.State.INVESTIGATE:
		return "Observation pause ended; committed last-seen destination retained"
	if d.state == ObservationDecisions.State.EXPLORE:
		return "Resume pause ended; return to authored exploration"
	if now - int(d.evidence.get("tick", -1)) >= d.freshness_ticks:
		return "Original evidence expired"
	if before == ObservationDecisions.State.INVESTIGATE and controller._failed:
		return "Path unavailable or blocked beyond retries"
	if before == ObservationDecisions.State.INVESTIGATE and controller._arrived:
		return "Physical area visit completed"
	var latest: Dictionary = controller.memory.inspect(now).get(d.evidence.get("subject"), {})
	if before == ObservationDecisions.State.OBSERVE and latest.get("source") == &"vision" and latest.get("tick", -1) == now:
		return "Still directly seen at pause end; no pursuit"
	return "Bounded response ended at deadline %d; inspect direct-memory/coordination trace" % deadline


func until(predicate: Callable, limit: int) -> bool:
	for frame in range(limit):
		if predicate.call():
			return true
		if _aborted:
			return false
		await step()
	return predicate.call()


func _observed(fact: Dictionary, index: int) -> void:
	_observations += 1
	if _observations > 512:
		fail("observation ledger exceeded 512 events")
		return
	if fact.get("tick", -1) != now or fact.get("observer") != IDS[index] or fact.get("subject") != &"F11" \
			or fact.get("source") != &"vision" or fact.get("event") != &"seen":
		fail("sensor fact has invalid time/identity/source/event provenance")
	var actor: CharacterMotor = controllers[index].motor
	var delta := human.global_position + Vector3.UP * 1.2 - (actor.global_position + Vector3.UP * 1.4)
	var forward: Vector3 = -actor.get_node("Visual").global_basis.z
	if not clear_ray(index) or delta.length() > sensors[index].range_units \
			or forward.dot(delta.normalized()) < cos(deg_to_rad(sensors[index].field_of_view_degrees / 2.0)) \
			or fact.position.distance_to(human.global_position) > 0.001:
		fail("observation emitted without physical range/cone/LOS witness")
	ledger[_key(fact)] = fact.duplicate(true)
	record("observation", fact.duplicate(true))
	semantics.append(["observed", fact.tick, String(fact.observer), _point(fact.position)])


func _audit() -> void:
	audits += 1
	for channel in channels:
		if channel.pending_count() > channel.capacity:
			fail("report queue exceeded capacity")
	for index in range(3):
		var controller: ObservationController = controllers[index]
		var facts := controller.memory.inspect(now)
		if facts.size() > controller.memory.capacity:
			fail("private memory exceeded capacity")
		for fact: Dictionary in facts.values():
			_check_origin(fact, index)
			var key := String(IDS[index]) + ":" + _key(fact) + ":" + String(fact.source)
			if not _remembered.has(key):
				_remembered[key] = true
				record("memory_received", {"recipient": IDS[index], "fact": fact})
		var d := controller.decisions
		if not d.evidence.is_empty():
			_check_origin(d.evidence, index)
			var signature := _key(d.evidence) + ":" + String(d.evidence.source)
			if d.state in [ObservationDecisions.State.OBSERVE, ObservationDecisions.State.INVESTIGATE]:
				if _committed.has(index) and _committed[index].signature == signature:
					if d.investigation_destination != _committed[index].destination:
						fail("committed destination changed without a new response")
				else:
					_committed[index] = {"signature": signature, "destination": d.investigation_destination}
				if d.state == ObservationDecisions.State.INVESTIGATE and not controller._failed \
						and controller._goal.distance_to(d.investigation_destination) > 0.751:
					fail("navigation goal is unrelated to committed legitimate evidence")
		if d.state == ObservationDecisions.State.EXPLORE and controller._started and not controller.waiting:
			var authored := false
			for site in world.sites:
				authored = authored or controller._goal.distance_to(site.position) <= 0.751
			if not authored:
				fail("exploration goal is not an authored static site")


func _check_origin(fact: Dictionary, recipient: int) -> void:
	var key := _key(fact)
	if not ledger.has(key):
		fail("UNSEEN_FACT: no actual observation for " + key)
		return
	var original: Dictionary = ledger[key].duplicate(true)
	if fact.source == &"team_report":
		var route := String(fact.observer) + ">" + String(IDS[recipient])
		if not routes.has(route) or now < int(fact.tick) + int(routes.get(route, 0)):
			fail("report not authorized or delivered before its delay")
		original.source = &"team_report"
	elif fact.observer != IDS[recipient]:
		fail("agent acquired another observer's direct sight")
	if fact != original:
		fail("observation age/position/provenance changed into unsupported world truth")


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		fail(label)


func fail(message: String) -> void:
	if message not in failures:
		failures.append(message)
	_aborted = true


func record(event: String, data: Dictionary) -> void:
	if trace.size() >= 2048:
		fail("diagnostic trace exceeded 2048 entries")
		return
	trace.append({"event": event, "tick": now, "data": data})


func result() -> Dictionary:
	return {"checks": checks, "failures": failures.duplicate(), "frames": frames_used,
		"audited_frames": audits, "observations": _observations, "state_changes": _state_events,
		"trace": trace.duplicate(true), "semantic_trace": semantics.duplicate(true)}


func cleanup() -> void:
	world.queue_free()
	for frame in range(3):
		await tree.physics_frame
		await tree.process_frame


func _key(fact: Dictionary) -> String:
	return "%s:%s:%d" % [fact.observer, fact.subject, fact.tick]


func _point(point: Vector3) -> Array:
	return [snappedf(point.x, 0.001), snappedf(point.y, 0.001), snappedf(point.z, 0.001)]
