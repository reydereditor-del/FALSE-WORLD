extends SceneTree

var checks: int = 0
var failures: int = 0
const S := ObservationDecisions.State


func _initialize() -> void:
	call_deferred("run")


func expect(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func report(tick: int, position: Vector3 = Vector3(3, 0, 1), subject: StringName = &"F11") -> Dictionary:
	return {"observer": &"K72", "subject": subject, "event": &"seen", "position": position,
		"tick": tick, "confidence": 1.0, "source": &"team_report"}


func decision(seed_value: int = 432) -> ObservationDecisions:
	var d := ObservationDecisions.new()
	d.coordination = ReportCoordination.new()
	d.teammate_ids = [&"K72", &"B14", &"D09"]
	d.initialize(seed_value)
	return d


func pure_checks() -> void:
	var d := decision()
	d.step(100, {}, Vector3(7, 0, 5))
	expect(d.state == S.EXPLORE, "no delivered evidence preserves exploration")
	var old := report(115)
	d.step(130, {&"F11": old}, Vector3(7, 0, 5))
	expect(d.state == S.OBSERVE and d.coordination.selected.action == "Check area",
		"fresh nearby delayed report starts a bounded area response")
	expect(d.evidence.position == old.position and d.evidence.tick == 115
		and d.investigation_destination.distance_to(old.position) > 1.0,
		"reported snapshot remains intact while approach is separate from occupancy")
	var fixed := d.investigation_destination
	old.position = Vector3(40, 0, 40)
	d.step(145, {&"F11": report(145, Vector3(8, 0, 1))}, Vector3(7, 0, 5))
	expect(d.investigation_destination == fixed and d.evidence.position == Vector3(3, 0, 1),
		"new reports cannot redirect a committed response or mutate pinned evidence")
	d.step(280, {}, Vector3(7, 0, 5))
	expect(d.state == S.INVESTIGATE, "seeded report pause leads to investigation")
	d.step(295, {}, Vector3(7, 0, 5), true)
	expect(d.state == S.RESUME, "completed coordinated visit resumes exploration")
	d.step(355, {}, Vector3(7, 0, 5))
	d.step(600, {&"F11": report(600)}, Vector3(7, 0, 5))
	expect(d.state == S.EXPLORE, "subject cooldown prevents immediate coordination loops")
	d.step(1200, {&"F11": report(1200)}, Vector3(7, 0, 5))
	expect(d.state == S.EXPLORE and d.coordination.inspect(1200, 300).reason.contains("handled"),
		"new timestamps at an already checked point never create repeated visits")
	var stale := decision()
	stale.step(220, {&"F11": report(100)}, Vector3(7, 0, 5))
	expect(stale.state == S.EXPLORE and stale.coordination.inspect(220, 300).decision == "Continue exploration",
		"report can remain in memory yet be too old for a new coordination response")
	var far := decision()
	far.step(100, {&"F11": report(100, Vector3(40, 0, 40))}, Vector3.ZERO)
	expect(far.state == S.EXPLORE and far.coordination.inspect(100, 300).reason.contains("distant"),
		"irrelevant distant reports do not cause map-wide travel")
	var future := decision()
	future.step(100, {&"F11": report(101)}, Vector3.ZERO)
	expect(future.state == S.EXPLORE, "future-dated reports cannot trigger coordination")
	var eta := decision()
	eta.freshness_ticks = 180
	eta.step(130, {&"F11": report(100)}, Vector3(7, 0, 5))
	expect(eta.state == S.EXPLORE and eta.coordination.inspect(130, 180).reason.contains("lifetime"),
		"insufficient pause and estimated travel budget preserves exploration")
	var near := decision()
	near.step(130, {&"F11": report(100)}, Vector3(3, 0, 2))
	near.step(280, {}, Vector3(3, 0, 2))
	expect(near.state == S.RESUME and near.coordination.selected.action == "Pause nearby",
		"recipient already near the area briefly observes without redundant convergence")
	var local := decision()
	var direct := report(100, Vector3(2, 0, 1), &"P20")
	direct.source = &"vision"
	local.step(130, {&"F11": report(125), &"P20": direct}, Vector3(7, 0, 5))
	expect(local.evidence.subject == &"P20" and local.coordination.inspect(130, 300).decision == "Local observation",
		"eligible direct local evidence takes priority over newer indirect evidence")
	var a := decision(431)
	var b := decision(432)
	var c := decision(433)
	var repeat := decision(432)
	for item in [a, b, c, repeat]:
		item.step(130, {&"F11": report(100)}, Vector3(7, 0, 5))
	expect(a.investigation_destination != b.investigation_destination
		and b.investigation_destination != c.investigation_destination
		and a.investigation_destination != c.investigation_destination,
		"three seeds choose distinct area approaches rather than one convergence point")
	expect(a._until != b._until and b._until != c._until
		and b._until == repeat._until and b.investigation_destination == repeat.investigation_destination,
		"response timing varies across agents and repeats with the same injected seed")
	var expired := decision()
	expired.step(130, {&"F11": report(100)}, Vector3(7, 0, 5))
	expired.step(250, {}, Vector3(7, 0, 5))
	expired.step(400, {}, Vector3(7, 0, 5))
	expect(expired.state == S.RESUME and expired.coordination.inspect(400, 300).reported_position == null,
		"expiry ends active response and removes actionable debug coordinates")
	var budget := decision()
	var facts: Dictionary = {}
	for index in range(100):
		var subject := StringName("P%d" % index)
		facts[subject] = report(0, Vector3(3, 0, 1), subject)
	for tick in range(130, 145):
		budget.step(tick, facts, Vector3(7, 0, 5))
	expect(budget.evaluations == 1 and budget.inspected_facts == 8 and budget.coordination.assessments == 8,
		"coordination cannot exceed eight assessments or its scheduled decision frequency")


func run() -> void:
	pure_checks()
	var world = load("res://scenes/prototype/stage3c_coordination.tscn").instantiate()
	root.add_child(world)
	var human := world.get_node("Character") as CharacterMotor
	human.get_node("LocalController").set_physics_process(false)
	human.get_node("LocalController").set_process_unhandled_input(false)
	await frames(90)
	expect(world.actors.size() == 4 and world.controllers.size() == 3
		and world.get_node("Ground/Mesh").mesh.size == Vector3(100, 0.5, 100),
		"coordination preserves the same 100-metre map and one-human/three-agent population")
	expect(world.max_sensors_per_tick == 1, "coordination decisions retain staggered local sampling")
	world.set_physics_process(false)
	for index in range(3):
		var controller := world.controllers[index] as ObservationController
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
		controller.memory = LocalMemory.new()
		world.sensors[index].memory = controller.memory
		controller.initialize()
		for connection in world.sensors[index].observed.get_connections():
			world.sensors[index].observed.disconnect(connection.callable)
	world.channel = ObservedFactChannel.new()
	for index in range(3):
		world.channel.register(world.sensors[index], world.sensors[(index + 1) % 3].observer_id,
			world.sensors[index].memory)
	var driver := world.controllers[0] as ObservationController
	var receiver := world.controllers[1] as ObservationController
	var outsider := world.controllers[2] as ObservationController
	var sensor: LocalPerception = world.sensors[0]
	driver.motor.position = Vector3(0, 0.1, 5)
	driver.motor.get_node("Visual").rotation.y = 0.0
	receiver.motor.position = Vector3(7, 0.1, 5)
	human.position = Vector3(3, 0.1, 1)
	outsider.motor.position = Vector3(-30, 0.1, 30)
	sensor.candidates = {&"F11": human}
	receiver.decisions.minimum_observe_ticks = 45
	receiver.decisions.maximum_observe_ticks = 45
	await frames(3)
	sensor.sample(1000)
	driver.plan(1000)
	var old_point: Vector3 = driver.decisions.evidence.position
	world.channel.advance(1029)
	receiver.plan(1029)
	expect(receiver.decisions.state == S.EXPLORE and receiver.memory.inspect(1029).is_empty(),
		"no recipient response or information exists before actual report delay")
	world.channel.advance(1030)
	receiver.plan(1045)
	expect(receiver.decisions.state == S.OBSERVE and receiver.decisions.evidence.tick == 1000
		and receiver.decisions.evidence.source == &"team_report",
		"properly delayed sensor report triggers local assessment with original provenance and age")
	expect(receiver.decisions._until != driver.decisions._until, "report and observer reactions are unsynchronized")
	expect(receiver.memory != driver.memory and outsider.memory.inspect(1045).is_empty(),
		"private memories and selective delivery remain independent")
	var fixed_approach := receiver.decisions.investigation_destination
	human.position = Vector3(3.5, 0.1, 1)
	await frames(3)
	sensor.sample(1060)
	human.position = Vector3(0, 0.1, -2)
	await frames(3)
	sensor.sample(1075)
	world.channel.advance(1090)
	receiver.plan(1105)
	expect(receiver.decisions.state == S.INVESTIGATE and receiver.decisions.evidence.position == old_point
		and receiver.navigator.target_position.distance_to(fixed_approach) < 0.2
		and receiver.memory.inspect(1105)[&"F11"].tick == 1060,
		"newer genuine delivered evidence never retargets a committed reported-area visit")
	var view := AIDebugState.read(receiver, 1105)
	expect(view.direct_position == null and view.coordination.uncertain and view.coordination.reporter == "K72"
		and view.coordination.age_ticks == 105 and view.coordination.decision == "Check area",
		"F3 explains coordination using old uncertain report, never fabricated direct vision")
	expect(AIDebugState.describe(view, 60).contains("uncertain last-seen"), "overlay text explicitly labels report uncertainty")
	var query_count := receiver.path_queries
	var assessment_count := receiver.decisions.coordination.assessments
	for tick in range(1106, 1120):
		receiver.plan(tick)
		AIDebugState.read(receiver, tick)
	expect(receiver.path_queries == query_count and receiver.decisions.coordination.assessments == assessment_count,
		"busy/duplicate calls and diagnostics cannot create repeated assessments or path requests")
	receiver.set_physics_process(true)
	var speed_ok := true
	for tick in range(180):
		await frames(1)
		if tick % 15 == 0:
			receiver.plan(1120 + tick)
		speed_ok = speed_ok and Vector2(receiver.motor.velocity.x, receiver.motor.velocity.z).length() <= human.move_speed + 0.001
		if receiver.decisions.state == S.RESUME:
			break
	expect(receiver.decisions.state == S.RESUME and receiver.motor.position.distance_to(fixed_approach) < 0.9,
		"recipient physically reaches the reported-area approach and resumes")
	expect(speed_ok and receiver.motor.is_on_floor(), "coordination uses unchanged human speed, gravity and ground collision")
	expect(receiver.decisions.investigation_destination == fixed_approach
		and fixed_approach.distance_to(human.position) > 4.0, "unseen human movement does not become a live investigation goal")
	receiver.set_physics_process(false)
	receiver.motor.set_move_intent(Vector3.ZERO)

	# True path length, not just straight distance, can reject an unaffordable detour.
	receiver.motor.position = Vector3(0, 0.1, 5)
	await frames(3)
	expect(not receiver.try_destination(Vector3(0, 0, -5), 10.1),
		"actual obstacle detour over travel budget is rejected using the existing validation query")
	# A valid reported point can yield an offset inside a wall; abandon rather than churn.
	receiver.seed_value = 431
	receiver.initialize()
	receiver.memory = LocalMemory.new()
	receiver.memory.remember(report(2000, Vector3(0, 0, 2)), 2000)
	receiver.plan(2000)
	query_count = receiver.path_queries
	receiver.plan(2150)
	receiver.plan(2165)
	expect(receiver.decisions.state == S.RESUME and receiver.path_queries - query_count == 1,
		"unreachable offset fails once then resumes instead of requesting alternate goals forever")

	var barrier := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, 3, 0.5)
	shape.shape = box
	barrier.add_child(shape)
	world.add_child(barrier)
	barrier.position = Vector3(0, 1.5, 8)
	receiver.motor.position = Vector3(0, 0.1, 5)
	driver.motor.position = Vector3(-30, 0.1, -30)
	human.position = Vector3(40, 0.1, 40)
	await frames(3)
	receiver.seed_value = 432
	receiver.initialize()
	receiver.stall_timeout_ticks = 30
	receiver.memory = LocalMemory.new()
	receiver.memory.remember(report(3000, Vector3(0, 0, 12)), 3000)
	receiver.plan(3000)
	receiver.plan(3060)
	receiver.set_physics_process(true)
	var retry_max := 0
	var abandoned_before := receiver.abandoned_paths
	for tick in range(220):
		await frames(1)
		if tick % 15 == 0:
			receiver.plan(3075 + tick)
			retry_max = maxi(retry_max, receiver.repath_attempts)
		if receiver.decisions.state == S.RESUME:
			break
	expect(receiver.decisions.state == S.RESUME and receiver.abandoned_paths > abandoned_before and retry_max <= 2,
		"physically blocked coordinated response retries finitely then abandons")
	expect(receiver.motor.position.z < 7.5, "coordinating recipient never passes through the physical blocker")
	world.queue_free()
	await frames(3)
	print("Stage3C: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
