extends SceneTree
## New map integration. Privileged fixture truth stays in tests, never in AI planners.

var checks := 0
var failures := 0
var area: Node3D
var human: CharacterMotor
var ledger: Dictionary = {}
var witnessed := true
var audited := true
var observations := 0
var started := 0
var ticks := 0


func _initialize() -> void:
	started = Time.get_ticks_msec()
	call_deferred("run")


func expect(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)


func frames(count: int) -> void:
	for frame in range(count):
		ticks += 1
		if ticks > 3500 or Time.get_ticks_msec() - started > 30000:
			push_error("Map AI incomplete: finite budget exceeded")
			quit(2)
			return
		await physics_frame
		await process_frame


func key(fact: Dictionary) -> String:
	return str(fact.observer) + ":" + str(fact.subject) + ":" + str(fact.tick)


func observed(fact: Dictionary, index: int) -> void:
	observations += 1
	var sensor: LocalPerception = area.sensors[index]
	var actor := sensor.actor
	var target: CharacterMotor = area.actors[fact.subject]
	var origin := actor.global_position + Vector3.UP * 1.4
	var point := target.global_position + Vector3.UP * 1.2
	var delta := point - origin
	var hit := actor.get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(origin, point, 1, [actor.get_rid()]))
	var valid: bool = (hit.is_empty() or hit.collider == target) and delta.length() <= 8.0
	valid = valid and (-actor.get_node("Visual").global_basis.z).dot(delta.normalized()) >= cos(deg_to_rad(60.0))
	valid = valid and fact.position.distance_to(target.global_position) < 0.001
	witnessed = witnessed and valid
	ledger[key(fact)] = fact.duplicate(true)


func audit() -> void:
	var now: int = area.simulation_tick
	for i in range(3):
		var sensor: LocalPerception = area.sensors[i]
		var snapshot := sensor.memory.inspect(now)
		audited = audited and snapshot.size() <= 8
		for fact: Dictionary in snapshot.values():
			if not ledger.has(key(fact)):
				audited = false
				continue
			var original: Dictionary = ledger[key(fact)]
			audited = audited and fact.position == original.position and now - fact.tick < 300
			if fact.source == &"vision":
				audited = audited and fact.observer == sensor.observer_id
			else:
				var source_ids := [&"D09", &"K72", &"B14"]
				audited = audited and now - fact.tick >= 30 and fact.observer == source_ids[i]
		audited = audited and area.controllers[i].memory == sensor.memory
	audited = audited and area.channel.pending_count() <= 12


func run() -> void:
	var world := load("res://scenes/world/map_foundation.tscn").instantiate() as Node3D
	root.add_child(world)
	area = world.get_node("LocalArea")
	human = area.get_node("Character")
	human.get_node("LocalController").set_physics_process(false)
	for i in range(3):
		area.sensors[i].observed.connect(observed.bind(i))
	var initial: Array[Vector3] = []
	for controller in area.controllers:
		initial.append(controller.motor.global_position)
	for tick in range(1200):
		await frames(1)
		audit()
	expect(area.actors.size() == 4 and area.controllers.size() == 3, "new map reuses one human and three real Stage 3C AI")
	expect(observations > 0 and witnessed and audited, "1200 ticks: actual ray/cone/range witnesses, private provenance, selective delay/expiry and queue bounds")
	expect(area.max_sensors_per_tick == 1, "unchanged staggered sensing, at most one sensor per tick")
	var map: RID = area.controllers[0].navigator.get_navigation_map()
	expect(NavigationServer3D.map_get_iteration_id(map) > 0, "local navigation synchronized")
	var valid := true
	for site in area.sites:
		var nearest := NavigationServer3D.map_get_closest_point(map, site.position)
		var path := NavigationServer3D.map_get_path(map, Vector3(220, 0, 140), nearest, true)
		valid = valid and nearest.distance_to(site.position) < 0.75 and not path.is_empty()
		if not path.is_empty():
			valid = valid and path[-1].distance_to(nearest) < 0.5
	expect(valid and area.sites.size() == 10, "all ten authored sites, including building interiors, are reachable on the new local bake")
	for i in range(3):
		var position: Vector3 = area.controllers[i].motor.global_position
		expect(position.distance_to(initial[i]) > 1 and absf(position.x - 220) < 45 and absf(position.z - 140) < 45,
			"real autonomous AI " + str(i) + " moves and stays within representative quarter")
	expect(area.get_node("NavigationRegion3D").navigation_mesh.get_polygon_count() < 500,
		"whole-map dense navigation not required: <500 local polygons")
	var overlay := area.get_node("AIDebugOverlay") as AIDebugOverlay
	expect(not overlay.enabled and overlay.refresh_count == 0, "developer diagnostics off and idle by default")
	# Freeze scheduler/executors for independent physical and knowledge cases.
	area.set_physics_process(false)
	for controller in area.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	var driver: ObservationController = area.controllers[0]
	var actor := driver.motor
	actor.global_position = Vector3(220, 0.1, 170)
	human.global_position = Vector3(260, 0.1, 180)
	area.controllers[1].motor.global_position = Vector3(180, 0.1, 180)
	area.controllers[2].motor.global_position = Vector3(185, 0.1, 180)
	await frames(20)
	var barrier := StaticBody3D.new()
	barrier.position = Vector3(220, 1.5, 174)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(8, 3, 0.5)
	collision.shape = shape
	barrier.add_child(collision)
	world.add_child(barrier)
	driver.memory = LocalMemory.new()
	driver.choices.sites = [{"id": &"test", "position": Vector3(220, 0, 178), "area": &"lane", "kind": &"transit"}]
	driver.initialize()
	driver.stall_timeout_ticks = 30
	driver.wait_until = 0
	var abandoned := driver.abandoned_paths
	driver.plan(3000)
	expect(not driver.waiting, "blocked-path test starts a valid real navigation path before the new physical obstruction")
	driver.set_physics_process(true)
	var retries := 0
	for tick in range(600):
		await frames(1)
		if tick % 15 == 0:
			driver.plan(3015 + tick)
			retries = maxi(retries, driver.repath_attempts)
		if driver.abandoned_paths > abandoned:
			break
	expect(driver.abandoned_paths > abandoned and retries <= 2 and actor.global_position.z < 173.5,
		"new-map physical blockage: <=2 retries then abandonment, no collision bypass")
	driver.set_physics_process(false)
	actor.set_move_intent(Vector3.ZERO)
	barrier.queue_free()
	# The real storehouse wall must block sensing; an interior witness permits it.
	var sensor: LocalPerception = area.sensors[0]
	sensor.memory = LocalMemory.new()
	sensor.candidates = {&"F11": human}
	actor.global_position = Vector3(204, 0.1, 118)
	actor.velocity = Vector3.ZERO
	human.global_position = Vector3(210, 0.1, 118)
	human.velocity = Vector3.ZERO
	actor.get_node("Visual").rotation.y = -PI / 2
	await frames(20)
	sensor.sample(5000)
	expect(sensor.memory.snapshot(5000).is_empty(), "new solid building wall blocks nearby human observation")
	human.global_position = Vector3(204, 0.1, 114)
	actor.get_node("Visual").rotation.y = 0
	await frames(20)
	var recipient := LocalMemory.new()
	var relay := ObservedFactChannel.new()
	relay.register(sensor, &"B14", sensor.memory)
	relay.register(area.sensors[1], &"D09", recipient)
	sensor.sample(5010)
	var snapshot := sensor.memory.snapshot(5010)
	expect(snapshot.has(&"F11"), "actual clear view inside storehouse creates observation")
	relay.advance(5039)
	expect(recipient.snapshot(5039).is_empty(), "new-map sight report does not arrive before 30-tick delay")
	relay.advance(5040)
	var received := recipient.snapshot(5040)
	expect(received.has(&"F11") and received[&"F11"].tick == 5010 and received[&"F11"].source == &"team_report",
		"delivered report preserves original time and indirect provenance")
	human.global_position = Vector3(210, 0.1, 118)
	await frames(20)
	sensor.sample(5050)
	var old := sensor.memory.snapshot(5050)
	expect(old.has(&"F11") and old[&"F11"].position.distance_to(Vector3(204, 0, 114)) < 0.15 and old[&"F11"].tick == 5010,
		"hidden human movement never refreshes remembered position or observation time")
	expect(sensor.memory.snapshot(5310).is_empty() and recipient.snapshot(5310).is_empty(), "direct and relayed facts expire without live tracking")
	world.queue_free()
	await frames(4)
	print("Map AI: %d checks, %d failures; complete=true; %d witnessed observations" % [checks, failures, observations])
	quit(0 if failures == 0 else 1)
