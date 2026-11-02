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


func fact(tick: int, point: Vector3 = Vector3(3, 0, 1), source: StringName = &"vision",
		subject: StringName = &"F11") -> Dictionary:
	return {"observer": &"K72", "subject": subject, "event": &"seen", "position": point,
		"tick": tick, "confidence": 1.0, "source": source}


func decision(seed_value: int = 431) -> ObservationDecisions:
	var d := ObservationDecisions.new()
	d.teammate_ids = [&"K72", &"B14", &"D09"]
	d.initialize(seed_value)
	return d


func pure_checks() -> void:
	var d := decision()
	d.step(100, {}, Vector3.ZERO)
	expect(d.state == S.EXPLORE, "no observation means ordinary exploration")
	var observed := fact(115)
	d.step(115, {&"F11": observed}, Vector3.ZERO)
	expect(d.state == S.OBSERVE, "fresh local observation starts observation pause")
	observed.position = Vector3(9, 0, 9)
	expect(d.evidence.position == Vector3(3, 0, 1), "decision evidence is an independent value snapshot")
	d.step(130, {&"F11": fact(130, Vector3(4, 0, 1))}, Vector3.ZERO)
	expect(d.state == S.OBSERVE and d.transitions == 1, "minimum dwell prevents immediate state switching")
	d.step(205, {}, Vector3.ZERO)
	expect(d.state == S.INVESTIGATE, "lost sight permits a visit to the known old location")
	d.step(220, {&"F11": fact(220, Vector3(8, 0, 1), &"team_report")}, Vector3.ZERO)
	expect(d.state == S.INVESTIGATE and d.evidence.position == Vector3(3, 0, 1)
		and d.evidence.tick == 115, "new reports never retarget an active investigation")
	d.step(235, {}, Vector3.ZERO, true)
	expect(d.state == S.RESUME, "arrival ends investigation and starts resume pause")
	d.step(295, {}, Vector3.ZERO)
	expect(d.state == S.EXPLORE, "resume returns to exploration")
	d.step(310, {&"F11": fact(310, Vector3(8, 0, 1))}, Vector3.ZERO)
	expect(d.state == S.EXPLORE, "global cooldown prevents switching immediately to another observation")
	d.step(550, {&"F11": fact(550, Vector3(8, 0, 1))}, Vector3.ZERO)
	expect(d.state == S.EXPLORE, "subject cooldown prevents repeated investigations of a moving target")
	d.step(1100, {&"F11": fact(1100)}, Vector3.ZERO)
	expect(d.state == S.EXPLORE, "newer timestamps at the same location do not create repeat loops")
	d.step(1115, {&"F11": fact(1115, Vector3(8, 0, 1))}, Vector3.ZERO)
	expect(d.state == S.OBSERVE, "later sufficiently changed evidence can justify a new response")

	var stale := decision()
	stale.step(500, {&"F11": fact(200)}, Vector3.ZERO)
	expect(stale.state == S.EXPLORE, "expired observation cannot trigger a decision at exact boundary")
	stale.step(515, {&"F11": fact(516)}, Vector3.ZERO)
	expect(stale.state == S.EXPLORE, "future observation cannot trigger a decision")
	stale.step(530, {&"F11": fact(530, Vector3(40, 0, 0), &"team_report")}, Vector3.ZERO)
	expect(stale.state == S.EXPLORE, "distant team reports do not cause map-wide pursuit")
	stale.step(545, {&"B14": fact(545, Vector3(1, 0, 0), &"vision", &"B14")}, Vector3.ZERO)
	expect(stale.state == S.EXPLORE, "known teammate sightings do not create mutual investigation loops")
	stale.step(560, {&"F11": fact(270, Vector3(3, 0, 1), &"team_report")}, Vector3.ZERO)
	expect(stale.state == S.OBSERVE, "still-fresh historical report can trigger observation")
	stale.step(575, {}, Vector3.ZERO)
	expect(stale.state == S.RESUME, "evidence expiring during observation cancels the visit")

	var visible := decision()
	visible.step(100, {&"F11": fact(100)}, Vector3.ZERO)
	visible.step(190, {&"F11": fact(190)}, Vector3.ZERO)
	expect(visible.state == S.RESUME, "continued direct sight produces a bounded look, not pursuit")
	var timeout := decision()
	timeout.investigation_timeout_ticks = 30
	timeout.step(100, {&"F11": fact(100)}, Vector3.ZERO)
	timeout.step(190, {}, Vector3.ZERO)
	timeout.step(220, {}, Vector3.ZERO)
	expect(timeout.state == S.RESUME, "travel has a hard investigation deadline")
	var failed := decision()
	failed.step(100, {&"F11": fact(100)}, Vector3.ZERO)
	failed.step(190, {}, Vector3.ZERO)
	failed.step(205, {}, Vector3.ZERO, false, true)
	expect(failed.state == S.RESUME, "unreachable or abandoned travel resumes exploration")
	var expiring := decision()
	expiring.step(100, {&"F11": fact(100)}, Vector3.ZERO)
	expiring.step(190, {}, Vector3.ZERO)
	expiring.step(400, {}, Vector3.ZERO)
	expect(expiring.state == S.RESUME, "stale evidence terminates travel before its execution timeout")

	var a := decision(431)
	var b := decision(431)
	var c := decision(432)
	for item in [a, b, c]:
		item.step(100, {&"F11": fact(100)}, Vector3.ZERO)
	expect(a._until == b._until and a._until != c._until, "seeded response duration is reproducible and differs across agents")
	var budget := decision()
	var many: Dictionary = {}
	for index in range(100):
		var subject := StringName("P%d" % index)
		many[subject] = fact(100, Vector3(40, 0, 0), &"team_report", subject)
	for tick in range(100, 115):
		budget.step(tick, many, Vector3.ZERO)
	expect(budget.evaluations == 1 and budget.inspected_facts == 8,
		"duplicate/frame-rate calls cannot exceed decision frequency or eight-fact scan")
	# Different reported subjects at one recently handled location cannot chain visits.
	var area := decision()
	area.step(100, {&"F11": fact(100)}, Vector3.ZERO)
	area.step(190, {}, Vector3.ZERO)
	area.step(205, {}, Vector3.ZERO, true)
	area.step(265, {}, Vector3.ZERO)
	area.step(600, {&"P20": fact(600, Vector3(3, 0, 1), &"team_report", &"P20")}, Vector3.ZERO)
	expect(area.state == S.EXPLORE, "location cooldown also prevents different subjects chaining visits")

	var stationary := decision()
	for tick in range(100, 3100, 15):
		stationary.step(tick, {&"F11": fact(tick)}, Vector3.ZERO)
	expect(stationary.transitions == 3 and stationary.state == S.EXPLORE,
		"continuous stationary sightings cause one bounded response, not investigation loops")


func run() -> void:
	pure_checks()
	var world = load("res://scenes/prototype/stage3b1_observation.tscn").instantiate()
	root.add_child(world)
	var human := world.get_node("Character") as CharacterMotor
	human.get_node("LocalController").set_physics_process(false)
	human.get_node("LocalController").set_process_unhandled_input(false)
	await frames(90)
	expect(world.actors.size() == 4 and world.sites.size() == 16
		and world.get_node("Ground/Mesh").mesh.size == Vector3(100, 0.5, 100),
		"new composition retains one human, three agents and authored environment")
	expect(world.max_sensors_per_tick == 1, "observation decisions retain staggered sensing/planning")
	var private_memories := true
	for index in range(3):
		private_memories = private_memories and world.controllers[index].memory == world.sensors[index].memory
		if index > 0:
			private_memories = private_memories and world.controllers[index].memory != world.controllers[0].memory
	expect(private_memories, "each decision adapter receives only its own separate memory")
	world.set_physics_process(false)
	for controller in world.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	var driver := world.controllers[0] as ObservationController
	var receiver := world.controllers[1] as ObservationController
	var outsider := world.controllers[2] as ObservationController
	var actor := driver.motor
	var sensor: LocalPerception = world.sensors[0]
	actor.position = Vector3(0, 0.1, 5)
	actor.get_node("Visual").rotation.y = 0.0
	human.position = Vector3(3, 0.1, 1)
	receiver.motor.position = Vector3(7, 0.1, 5)
	outsider.motor.position = Vector3(-30, 0.1, 30)
	for controller in world.controllers:
		controller.memory = LocalMemory.new()
		controller.initialize()
	for index in range(3):
		world.sensors[index].memory = world.controllers[index].memory
	sensor.candidates = {&"F11": human}
	world.channel = ObservedFactChannel.new()
	for index in range(3):
		# Disconnect the original composition channel before isolating this fixture.
		for connection in world.sensors[index].observed.get_connections():
			world.sensors[index].observed.disconnect(connection.callable)
		world.channel.register(world.sensors[index], world.sensors[(index + 1) % 3].observer_id,
			world.sensors[index].memory)
	await frames(3)
	sensor.sample(1000)
	driver.plan(1000)
	expect(driver.decisions.state == S.OBSERVE, "real clear LOS sample drives observation state")
	var original: Vector3 = driver.decisions.evidence.position
	receiver.plan(1000)
	expect(receiver.decisions.state == S.EXPLORE, "receiver has no decision evidence before delivery")
	# The real central obstacle occludes the human after movement to its far side.
	human.position = Vector3(0, 0.1, -2)
	await frames(3)
	sensor.sample(1015)
	driver.plan(1015)
	expect(driver.memory.snapshot(1015)[&"F11"].tick == 1000,
		"solid LOS loss leaves old memory intact without live-position refresh")
	world.channel.advance(1029)
	receiver.plan(1029)
	expect(receiver.decisions.state == S.EXPLORE, "delayed report cannot trigger an early response")
	world.channel.advance(1030)
	receiver.plan(1045)
	expect(receiver.decisions.state == S.OBSERVE and receiver.decisions.evidence.tick == 1000
		and receiver.decisions.evidence.source == &"team_report"
		and receiver.decisions.evidence.position == original,
		"proper delivered report drives recipient using original age and position")
	outsider.plan(1045)
	expect(outsider.decisions.state == S.EXPLORE, "unaddressed third agent has no globally shared evidence")
	driver.plan(1090)
	expect(driver.decisions.state == S.INVESTIGATE and driver.navigator.target_position.distance_to(original) < 0.2,
		"navigation target is the frozen last-seen location, not hidden human position")
	var pinned_target := driver.navigator.target_position
	var query_count := driver.path_queries
	driver.plan(1091)
	expect(driver.path_queries == query_count, "adapter rejects excessive-frequency path/decision calls")
	driver.set_physics_process(true)
	var speed_ok := true
	for tick in range(180):
		await frames(1)
		if tick % 15 == 0:
			driver.plan(1105 + tick)
		speed_ok = speed_ok and Vector2(actor.velocity.x, actor.velocity.z).length() <= human.move_speed + 0.001
		if driver.decisions.state == S.RESUME:
			break
	expect(driver.decisions.state == S.RESUME and actor.position.distance_to(original) < 0.9,
		"agent physically visits remembered point and finishes the bounded investigation")
	expect(speed_ok and actor.is_on_floor(), "observation travel preserves shared speed and ground rules")
	expect(pinned_target.distance_to(human.position) > 4.0, "hidden human remains elsewhere while investigation ends")

	# Return to normal authored exploration, retaining private visit history.
	driver.set_physics_process(false)
	actor.set_move_intent(Vector3.ZERO)
	driver.memory = LocalMemory.new()
	driver.plan(1400)
	var selections_before := driver.selections
	driver.plan(1415)
	expect(driver.decisions.state == S.EXPLORE and driver.selections >= selections_before
		and not driver.waiting, "completed response resumes the existing static-site exploration")

	# A delayed observation that has expired at receipt never drives a recipient.
	receiver.memory = LocalMemory.new()
	receiver.memory.freshness_ticks = 10
	world.sensors[1].memory = receiver.memory
	receiver.initialize()
	var expiring_channel := ObservedFactChannel.new()
	expiring_channel.register(world.sensors[0], &"B14", driver.memory)
	expiring_channel.register(world.sensors[1], &"D09", receiver.memory)
	sensor.memory = driver.memory
	actor.position = Vector3(0, 0.1, 5)
	actor.get_node("Visual").rotation.y = 0.0
	human.position = Vector3(3, 0.1, 1)
	await frames(3)
	sensor.sample(1500)
	expiring_channel.advance(1530)
	receiver.plan(1530)
	expect(receiver.memory.snapshot(1530).is_empty() and receiver.decisions.state == S.EXPLORE,
		"report expired on actual delivery cannot trigger recipient decisions")

	# A valid last-seen snapshot can still be off the static navmesh; fail once.
	driver.initialize()
	driver.memory = LocalMemory.new()
	driver.decisions.maximum_distance = 200.0
	driver.memory.remember(fact(2000, Vector3(80, 0, 80), &"team_report"), 2000)
	driver.plan(2000)
	var queries_before := driver.path_queries
	driver.plan(2090)
	driver.plan(2105)
	expect(driver.decisions.state == S.RESUME and driver.path_queries - queries_before == 1,
		"off-navmesh investigation fails one bounded query then resumes")

	# Real physical blockage reuses finite retries and returns feedback to the state machine.
	var barrier := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, 3, 0.5)
	shape.shape = box
	barrier.add_child(shape)
	world.add_child(barrier)
	barrier.position = Vector3(0, 1.5, 8)
	actor.position = Vector3(0, 0.1, 5)
	human.position = Vector3(40, 0.1, 40)
	await frames(3)
	driver.initialize()
	driver.stall_timeout_ticks = 30
	driver.memory = LocalMemory.new()
	driver.memory.remember(fact(3000, Vector3(0, 0, 12), &"team_report"), 3000)
	driver.plan(3000)
	driver.plan(3090)
	driver.set_physics_process(true)
	var retry_max := 0
	var abandoned_before := driver.abandoned_paths
	for tick in range(200):
		await frames(1)
		if tick % 15 == 0:
			driver.plan(3105 + tick)
			retry_max = maxi(retry_max, driver.repath_attempts)
		if driver.decisions.state == S.RESUME:
			break
	expect(driver.decisions.state == S.RESUME and driver.abandoned_paths > abandoned_before
		and retry_max <= 2, "physically blocked investigation retries finitely then resumes")
	expect(actor.position.z < 7.5, "observation-driven movement never passes through the blocker")
	world.queue_free()
	await frames(3)
	print("Stage3B1: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
