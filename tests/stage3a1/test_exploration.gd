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


func sequence(sites: Array[Dictionary], seed_value: int) -> Array:
	var chooser := ExplorationChoices.new()
	chooser.sites = sites.duplicate(true)
	chooser.initialize(seed_value)
	var result: Array = []
	var now := 0
	var position := Vector3.ZERO
	for step in range(16):
		var selected := chooser.choose(position, now)
		var wait := chooser.arrived(selected)
		result.append([selected, wait])
		now += wait + 60
		position = sites[selected].position
	return result


func run() -> void:
	var world = load("res://scenes/prototype/stage3a1_exploration.tscn").instantiate()
	root.add_child(world)
	var human := world.get_node("Character") as CharacterMotor
	human.get_node("LocalController").set_physics_process(false)
	human.get_node("LocalController").set_process_unhandled_input(false)
	var first_ticks := [-1, -1, -1]
	for tick in range(120):
		await frames(1)
		for index in range(3):
			if first_ticks[index] < 0 and world.controllers[index].selections > 0:
				first_ticks[index] = tick
	expect(world.actors.size() == 4, "only one human and three AI in exploration scene")
	expect(world.sites.size() == 16, "sixteen bounded authored destinations")
	expect(world.get_node("Ground/Mesh").mesh.size == Vector3(100, 0.5, 100), "100 by 100 metre authored test area")
	expect(world.max_sensors_per_tick == 1, "perception and decisions remain staggered")
	expect(first_ticks[0] >= 0 and first_ticks[1] >= 0 and first_ticks[2] >= 0,
		"all agents leave their initial observation pauses")
	expect(first_ticks[0] != first_ticks[1] and first_ticks[1] != first_ticks[2],
		"agents start travel at different simulation ticks")
	var goals: Dictionary = {}
	for controller in world.controllers:
		goals[controller.index] = true
	expect(goals.size() >= 2, "default agents do not all select the same first destination")
	var sites: Array[Dictionary] = world.sites
	var a := sequence(sites, 431)
	var b := sequence(sites, 431)
	var c := sequence(sites, 432)
	expect(a == b, "same seed repeats destinations and wait durations")
	expect(a != c, "different seeds vary decisions and timing")
	var visited: Dictionary = {}
	var waits: Dictionary = {}
	var no_immediate_repeats := true
	for index in range(a.size()):
		visited[a[index][0]] = true
		waits[a[index][1]] = true
		if index > 0:
			no_immediate_repeats = no_immediate_repeats and a[index][0] != a[index - 1][0]
	expect(visited.size() >= 8 and waits.size() > 3, "visits explore multiple places with varied observation durations")
	expect(no_immediate_repeats, "visit history prevents immediate destination repeats")
	var chooser := ExplorationChoices.new()
	chooser.sites = [{"id": &"test", "position": Vector3(10, 0, 0), "area": &"a", "kind": &"observe"}]
	chooser.initialize(1)
	chooser.reject(0, 100)
	expect(chooser.choose(Vector3.ZERO, 999) == -1 and chooser.choose(Vector3.ZERO, 1000) == 0,
		"failed destination cooldown has deterministic expiry")

	world.set_physics_process(false)
	for controller in world.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	var driver := world.controllers[0] as ExplorationController
	var actor := driver.motor
	var map := driver.navigator.get_navigation_map()
	var reachable := true
	for site in sites:
		var nearest := NavigationServer3D.map_get_closest_point(map, site.position)
		var path := NavigationServer3D.map_get_path(map, Vector3(0, 0, 5), nearest, true)
		reachable = reachable and nearest.distance_to(site.position) < 0.75 and not path.is_empty()
		if not path.is_empty():
			reachable = reachable and path[-1].distance_to(nearest) < 0.5
	expect(reachable, "all authored sites are on reachable ground navigation")
	expect(world.get_node("NavigationRegion3D").navigation_mesh.get_polygon_count() < 500,
		"compact static navigation stays below 500 polygons")
	expect(human.facing_turn_speed == 0.0 and actor.facing_turn_speed == 3.5,
		"AI opt into smooth facing while M1 human default is preserved")

	# Actual path across the retained central obstacle, using shared collision/motor.
	actor.position = Vector3(0, 0.1, 5)
	human.position = Vector3(40, 0, 40)
	world.controllers[1].motor.position = Vector3(-40, 0, 40)
	world.controllers[2].motor.position = Vector3(40, 0, -40)
	await frames(3)
	driver.choices.sites = [{"id": &"cross", "position": Vector3(0, 0, -5), "area": &"test", "kind": &"observe"}]
	driver.initialize()
	driver.wait_until = 0
	driver.plan(1000)
	driver.set_physics_process(true)
	var previous_yaw: float = actor.get_node("Visual").rotation.y
	var side := 0.0
	var speed_ok := true
	var turn_ok := true
	var previous := actor.position
	var travel_distance := 0.0
	var planned_length := 0.0
	var planned_path := NavigationServer3D.map_get_path(map, actor.position, Vector3(0, 0, -5), true)
	for point in range(1, planned_path.size()):
		planned_length += planned_path[point - 1].distance_to(planned_path[point])
	var last_plan_tick := 1000
	var steps_ok := true
	for tick in range(360):
		await frames(1)
		if tick % 15 == 0:
			last_plan_tick = 1015 + tick
			driver.plan(last_plan_tick)
		side = maxf(side, absf(actor.position.x))
		speed_ok = speed_ok and Vector2(actor.velocity.x, actor.velocity.z).length() <= human.move_speed + 0.001
		var yaw: float = actor.get_node("Visual").rotation.y
		turn_ok = turn_ok and absf(angle_difference(previous_yaw, yaw)) <= driver.turn_speed / 60.0 + 0.01
		steps_ok = steps_ok and Vector2(actor.position.x - previous.x, actor.position.z - previous.z).length() < 0.15
		travel_distance += Vector2(actor.position.x - previous.x, actor.position.z - previous.z).length()
		previous = actor.position
		previous_yaw = yaw
		if actor.position.distance_to(Vector3(0, 0, -5)) < 0.65:
			break
	expect(side > 1.8 and actor.position.distance_to(Vector3(0, 0, -5)) < 0.8,
		"smoothed agent follows a valid detour around solid obstacle")
	expect(speed_ok and steps_ok, "steering never exceeds shared speed or teleports")
	expect(turn_ok, "visual yaw change is bounded by configurable turn speed")
	expect(travel_distance <= planned_length * 1.4 + 1.0, "travel avoids excessive path backtracking")
	driver.plan(last_plan_tick + 15)
	expect(driver.waiting and driver.wait_until > last_plan_tick + 15, "arrival produces a real wait-and-observe state")
	await frames(12)
	expect(Vector2(actor.velocity.x, actor.velocity.z).length() < 0.01, "waiting agent eases to a stationary observation pause")
	driver.set_physics_process(false)
	actor.set_move_intent(Vector3.ZERO)

	# Destination is not on this navmesh: reject rather than walking into a boundary.
	driver.choices.sites = [{"id": &"outside", "position": Vector3(80, 0, 80), "area": &"test", "kind": &"investigate"}]
	driver.initialize()
	driver.wait_until = 0
	var queries_before := driver.path_queries
	driver.plan(2000)
	expect(driver.failed_destinations > 0 and driver.waiting, "unreachable destination is rejected")
	expect(driver.path_queries - queries_before <= 2, "path validation work is bounded per decision")

	# A new collision wall absent from the baked map causes actual physical blocking.
	var barrier := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, 3, 0.5)
	shape.shape = box
	barrier.add_child(shape)
	world.add_child(barrier)
	barrier.position = Vector3(0, 1.5, 8)
	actor.position = Vector3(0, 0.1, 5)
	await frames(3)
	driver.choices.sites = [{"id": &"blocked", "position": Vector3(0, 0, 12), "area": &"test", "kind": &"transit"}]
	driver.initialize()
	driver.stall_timeout_ticks = 30
	driver.wait_until = 0
	driver.plan(3000)
	driver.set_physics_process(true)
	var abandoned_before := driver.abandoned_paths
	var retry_max := 0
	for tick in range(300):
		await frames(1)
		if tick % 15 == 0:
			driver.plan(3015 + tick)
			retry_max = maxi(retry_max, driver.repath_attempts)
		if driver.abandoned_paths > abandoned_before:
			break
	expect(driver.abandoned_paths > abandoned_before and retry_max <= 2,
		"physically blocked travel retries finitely then abandons destination")
	expect(actor.position.z < 7.5, "blocked agent never passes through added wall")
	world.queue_free()
	await frames(3)
	print("Stage3A1: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
