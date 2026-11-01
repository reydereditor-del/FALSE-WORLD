extends SceneTree

var checks: int = 0
var failures: int = 0


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


func fact(subject: StringName, tick: int) -> Dictionary:
	return {"observer": &"K72", "subject": subject, "event": &"seen",
		"position": Vector3(1, 0, 2), "tick": tick, "confidence": 1.0, "source": &"vision"}


func run() -> void:
	var memory := LocalMemory.new()
	memory.capacity = 2
	memory.freshness_ticks = 10
	expect(memory.remember(fact(&"F11", 10), 10), "memory accepts an observation at current tick")
	expect(not memory.remember(fact(&"F11", 9), 10), "older observation cannot overwrite newer evidence")
	expect(not memory.remember(fact(&"F11", 12), 11), "future observation rejected")
	var malformed := fact(&"F11", 10)
	malformed["hp"] = 100
	expect(not memory.remember(malformed, 10), "unsupported world-state fields rejected")
	malformed = fact(&"F11", 10)
	malformed.position = Vector3(INF, 0, 0)
	expect(not memory.remember(malformed, 10), "non-finite observation rejected")
	var view := memory.snapshot(10)
	view[&"F11"].position = Vector3(99, 0, 0)
	expect(memory.snapshot(10)[&"F11"].position == Vector3(1, 0, 2), "memory snapshot cannot mutate stored facts")
	memory.remember(fact(&"B14", 11), 11)
	memory.remember(fact(&"D09", 12), 12)
	expect(memory.snapshot(12).size() == 2 and not memory.snapshot(12).has(&"F11"), "memory capacity evicts oldest deterministically")
	expect(memory.snapshot(22).is_empty(), "facts expire at exact freshness boundary")
	expect(not memory.remember(fact(&"F11", 1), 22), "stale received fact rejected")

	var world = load("res://scenes/prototype/stage3a_local.tscn").instantiate()
	root.add_child(world)
	var human := world.get_node("Character") as CharacterMotor
	human.get_node("LocalController").set_physics_process(false)
	human.get_node("LocalController").set_process_unhandled_input(false)
	var initial: Array[Vector3] = []
	for controller: WaypointController in world.controllers:
		initial.append(controller.motor.global_position)
	await frames(120)
	expect(world.actors.size() == 4 and world.controllers.size() == 3, "exactly one local human and three AI bodies")
	expect(world.max_sensors_per_tick == 1, "three perception updates are staggered, not simultaneous")
	var moving := true
	var bounded := true
	var grounded := true
	var shared_model := true
	for index in range(3):
		var controller: WaypointController = world.controllers[index]
		var actor := controller.motor
		moving = moving and actor.global_position.distance_to(initial[index]) > 0.5
		bounded = bounded and Vector2(actor.velocity.x, actor.velocity.z).length() <= human.move_speed + 0.001
		grounded = grounded and actor.is_on_floor()
		shared_model = shared_model and actor.get_node("Visual/Body").mesh == human.get_node("Visual/Body").mesh
		shared_model = shared_model and actor.get_node("CollisionShape3D").shape == human.get_node("CollisionShape3D").shape
		expect(world.sensors[index].samples_taken > 0, "agent %d has scheduled local samples" % index)
		controller.set_physics_process(false)
		actor.set_move_intent(Vector3.ZERO)
	expect(moving, "all three agents actually traverse the baked navigation map")
	expect(bounded and grounded, "AI obey human motor speed and ground collision")
	expect(shared_model, "human and AI share exact mesh/collision resources")
	world.set_physics_process(false)

	# Static occluder is the real central box. Driver has no direct sight of the target.
	var observer: CharacterMotor = world.controllers[0].motor
	var sensor: LocalPerception = world.sensors[0]
	observer.position = Vector3(0, 0, 3)
	observer.get_node("Visual").rotation.y = 0.0
	human.position = Vector3(0, 0, -3)
	sensor.candidates = {&"F11": human}
	sensor.memory = LocalMemory.new()
	await frames(3)
	sensor.sample(100)
	expect(sensor.memory.snapshot(100).is_empty(), "solid obstacle blocks otherwise in-range vision")
	human.position = Vector3(3, 0, 1)
	await frames(3)
	sensor.sample(101)
	expect(sensor.memory.snapshot(101).has(&"F11"), "clear in-cone line of sight produces a local fact")
	var seen: Dictionary = sensor.memory.snapshot(101)[&"F11"]
	expect(seen.observer == &"K72" and seen.source == &"vision" and seen.tick == 101,
		"observation retains observer, source and sample time")
	human.position = Vector3(9, 0, 9)
	await frames(3)
	sensor.sample(102)
	expect(sensor.memory.snapshot(102)[&"F11"].position == seen.position,
		"unseen target movement never refreshes last-seen position")
	human.position = Vector3(0, 0, 6)
	await frames(3)
	sensor.sample(103)
	expect(sensor.memory.snapshot(103)[&"F11"].tick == 101, "behind-observer target fails field of view")
	human.position = Vector3(10, 0, -3)
	await frames(3)
	sensor.sample(104)
	expect(sensor.memory.snapshot(104)[&"F11"].tick == 101, "outside-range target cannot update memory")
	expect(sensor.memory.snapshot(401).is_empty(), "local last-seen expires without live GPS")

	var channel := ObservedFactChannel.new()
	var receiver := LocalPerception.new()
	receiver.observer_id = &"B14"
	receiver.memory = LocalMemory.new()
	world.add_child(receiver)
	var outsider := LocalPerception.new()
	outsider.observer_id = &"D09"
	outsider.memory = LocalMemory.new()
	world.add_child(outsider)
	channel.register(sensor, &"B14", sensor.memory)
	channel.register(receiver, &"D09", receiver.memory)
	channel.register(outsider, &"K72", outsider.memory)
	human.position = Vector3(3, 0, 1)
	await frames(3)
	sensor.sample(500)
	expect(channel.pending_count() == 1 and receiver.memory.snapshot(500).is_empty(), "observed facts queue without immediate broadcast")
	sensor.sample(501)
	expect(channel.pending_count() == 1, "repeated sightings coalesce within bounded queue")
	channel.advance(529)
	expect(receiver.memory.snapshot(529).is_empty(), "report delay enforced")
	channel.advance(530)
	var report: Dictionary = receiver.memory.snapshot(530)[&"F11"]
	expect(report.tick == 500 and report.observer == &"K72" and report.source == &"team_report",
		"delivery retains actual observation age and provenance")
	expect(outsider.memory.snapshot(530).is_empty(), "only configured recipient receives report; no relay chain")
	expect(sensor.memory.snapshot(530)[&"F11"].source == &"vision", "recipient report does not mutate observer's local memory")
	var forged := report.duplicate(true)
	forged.source = &"vision"
	forged.position = Vector3(100, 0, 100)
	sensor.observed.emit(forged)
	expect(channel.pending_count() == 0 and sensor.memory.snapshot(530)[&"F11"].tick == 501,
		"channel rejects unsupported fact without altering sensor memory")
	sensor.sample(600)
	receiver.memory.freshness_ticks = 10
	channel.advance(630)
	expect(receiver.memory.snapshot(630).is_empty(), "delayed facts expired at recipient are discarded")
	channel.capacity = 1
	var third: CharacterMotor = world.controllers[2].motor
	third.position = Vector3(2, 0, 1)
	sensor.candidates = {&"F11": human, &"D09": third}
	await frames(3)
	sensor.sample(700)
	sensor.sample(701)
	expect(sensor.memory.snapshot(701).size() == 2 and channel.pending_count() == 1,
		"two genuine observations cannot overflow a one-report queue")
	third.position = Vector3(9, 0, 9)
	sensor.candidates = {&"D09": third, &"F11": human}
	sensor.max_candidates = 1
	await frames(3)
	sensor.sample(702)
	expect(sensor.memory.snapshot(702)[&"F11"].tick == 701, "perception candidate work budget is enforced")
	sensor.max_candidates = 4

	# Re-route only the test agent directly across the real central obstacle.
	var driver: WaypointController = world.controllers[0]
	observer.position = Vector3(0, 0.1, 4)
	world.controllers[1].motor.position = Vector3(8, 0, 8)
	world.controllers[2].motor.position = Vector3(-8, 0, 8)
	human.position = Vector3(8, 0, -8)
	await frames(3)
	driver.waypoints = PackedVector3Array([Vector3(0, 0, -4)])
	driver.initialize()
	driver.plan(800)
	driver.set_physics_process(true)
	var side_excursion := 0.0
	var speed_ok := true
	var never_inside := true
	for index in range(240):
		await frames(1)
		side_excursion = maxf(side_excursion, absf(observer.position.x))
		speed_ok = speed_ok and Vector2(observer.velocity.x, observer.velocity.z).length() <= human.move_speed + 0.001
		never_inside = never_inside and not (absf(observer.position.x) < 1.49 and absf(observer.position.z) < 0.99)
		if observer.position.distance_to(Vector3(0, 0, -4)) < 0.5:
			break
	expect(side_excursion > 1.8, "Godot navigation routes around obstacle, not straight through it")
	expect(observer.position.distance_to(Vector3(0, 0, -4)) < 0.5, "agent reaches target on opposite side of obstacle")
	expect(speed_ok and never_inside, "navigated movement obeys speed and solid-body constraints")
	driver.set_physics_process(false)
	observer.set_move_intent(Vector3.ZERO)
	driver.waypoints = PackedVector3Array([Vector3(-6, 0, -5), Vector3(6, 0, -5), Vector3(6, 0, 5)])
	driver.initialize()
	var seeded_index := driver.index
	driver.initialize()
	expect(driver.index == seeded_index, "same injected seed repeats initial waypoint decision")
	# Force stalled physical execution, while exercising bounded planner retries.
	driver.plan(1000)
	for tick in range(1015, 1600, 15):
		driver.plan(tick)
	expect(driver.abandoned_paths > 0 and driver.repath_attempts <= 2,
		"stalled route is retried finitely then abandoned")
	world.queue_free()
	await frames(3)
	print("Stage3A: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
