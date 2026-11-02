extends SceneTree
## Real new scene + unchanged production motor. Poses only change between independent walks.

var checks := 0
var failures := 0
var frames_used := 0
var started := 0
var world: Node3D
var area: Node3D
var actor: CharacterMotor
var measurements: Array[Dictionary] = []


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
		frames_used += 1
		if frames_used > 65000 or Time.get_ticks_msec() - started > 180000:
			push_error("Map test incomplete: finite frame/wall budget exhausted")
			quit(2)
			return
		await physics_frame
		await process_frame


func ground(point: Vector3) -> Dictionary:
	# Jolt ray/triangle-edge precision: sample a 1 cm support footprint on misses.
	# The continuous TerrainSeam walking case additionally exercises physical support.
	for offset in [Vector2.ZERO, Vector2(0.01, 0), Vector2(0, 0.01)]:
		var hit := actor.get_world_3d().direct_space_state.intersect_ray(
			PhysicsRayQueryParameters3D.create(Vector3(point.x + offset.x, 100, point.z + offset.y), Vector3(point.x + offset.x, -10, point.z + offset.y), 1, [actor.get_rid()]))
		if not hit.is_empty():
			return hit
	return {}


func place(point: Vector3) -> void:
	actor.global_position = point + Vector3.UP * 0.1
	actor.velocity = Vector3.ZERO
	actor.set_move_intent(Vector3.ZERO)
	await frames(20)


func walking(label: String, path: PackedVector3Array) -> void:
	await place(path[0])
	var previous := actor.global_position
	var distance := 0.0
	var steps := 0
	var airborne := 0
	var max_airborne := 0
	var penetration := false
	var speed_ok := true
	var checkpoint_ok := true
	var query := PhysicsShapeQueryParameters3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.22
	capsule.height = 1.4
	query.shape = capsule
	query.collision_mask = 1
	query.exclude = [actor.get_rid()]
	for i in range(1, path.size()):
		var target := path[i]
		var limit := ceili(actor.global_position.distance_to(target) / 4.0 * 60 * 1.5) + 180
		var reached := false
		for tick in range(limit):
			var offset := target - actor.global_position
			offset.y = 0
			if offset.length() < 0.22:
				reached = true
				break
			actor.set_move_intent(offset.normalized())
			await frames(1)
			steps += 1
			var delta := actor.global_position - previous
			distance += delta.length()
			speed_ok = speed_ok and Vector2(delta.x, delta.z).length() < 0.08
			previous = actor.global_position
			airborne = 0 if actor.is_on_floor() else airborne + 1
			max_airborne = maxi(max_airborne, airborne)
			if steps % 15 == 0:
				query.transform = Transform3D(Basis.IDENTITY, actor.global_position + Vector3.UP)
				penetration = penetration or not actor.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
			if airborne > 8:
				break
		checkpoint_ok = checkpoint_ok and reached
		if not reached:
			print("Walk stopped ", label, " checkpoint ", i, " at ", actor.global_position, " target ", target)
			break
	actor.set_move_intent(Vector3.ZERO)
	expect(checkpoint_ok, label + ": every checkpoint reached by continuous physics walking")
	expect(max_airborne <= 4 and not penetration and speed_ok, label + ": grounded, no deep penetration or speed advantage")
	measurements.append({"route": label, "metres_walked": distance, "physics_ticks": steps, "simulated_seconds": steps / 60.0, "completed": checkpoint_ok})
	print("WALK ", label, ": ", snappedf(distance, 0.1), " m / ", snappedf(steps / 60.0, 0.1), " simulated s")


func run() -> void:
	world = load("res://scenes/world/map_foundation.tscn").instantiate()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.own_world_3d = true
	root.add_child(viewport)
	viewport.add_child(world)
	area = world.get_node("LocalArea")
	actor = area.get_node("Character")
	actor.get_node("LocalController").set_physics_process(false)
	area.set_physics_process(false)
	for controller in area.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	await frames(10)
	expect(actor.move_speed == 4.0 and actor.gravity == 18.0, "unchanged real CharacterMotor, no jump or speed override")
	var samples := 0
	var valid := true
	var clearance := true
	var body_query := PhysicsShapeQueryParameters3D.new()
	var body_shape := CapsuleShape3D.new()
	body_shape.radius = 0.36
	body_shape.height = 1.8
	body_query.shape = body_shape
	body_query.exclude = [world.get_node("Terrain").get_rid()]
	for body in area.actors.values():
		body_query.exclude += [body.get_rid()]
	for route: PackedVector3Array in MapLayout.routes().values():
		for i in range(1, route.size()):
			var n := ceili(route[i - 1].distance_to(route[i]) / 5)
			for step in range(n + 1):
				var point := route[i - 1].lerp(route[i], float(step) / n)
				var hit := ground(point)
				body_query.transform = Transform3D(Basis.IDENTITY, MapLayout.point(point.x, point.z, 0.95))
				clearance = clearance and actor.get_world_3d().direct_space_state.intersect_shape(body_query, 1).is_empty()
				valid = valid and not hit.is_empty()
				if not hit.is_empty():
					valid = valid and hit.normal.y > cos(deg_to_rad(25)) and absf(hit.position.y - MapLayout.height(point.x, point.z)) < 0.02
				samples += 1
	expect(valid and samples > 500, "all required road centerlines sampled every <=5 m have terrain support / slopes <=25 degrees (" + str(samples) + " samples)")
	expect(clearance, "sampled road centerlines clear the real character capsule envelope of static obstacles")
	valid = true
	for x in [-490, -250, 0, 250, 490]:
		for z in [-490, -250, 0, 250, 490]:
			valid = valid and not ground(Vector3(x, 0, z)).is_empty()
	expect(valid, "25 distributed footprint samples are real colliding ground")
	for marker in world.get_node("AuthoringMarkers").get_children():
		await place(marker.global_position)
		expect(actor.is_on_floor() and absf(actor.global_position.y - MapLayout.height(actor.global_position.x, actor.global_position.z)) < 0.12,
			"safe grounded editor marker " + String(marker.name))
	# Continuous full approach walks. Reversal tests actual descent without moving the actor.
	for label in ["StationWest", "StationEast", "SummitEast", "SummitSouth", "ForestPath"]:
		var route: PackedVector3Array = MapLayout.routes()[label]
		await walking(label, route)
		if String(label).begins_with("Summit"):
			route.reverse()
			# walking sets up at the endpoint just reached; the descent itself never teleports.
			await walking(String(label) + "Descent", route)
	await walking("BuildingEntrance", PackedVector3Array([Vector3(200, 0, 130), Vector3(200, 0, 118), Vector3(200, 0, 107)]))
	await walking("BuildingCorner", PackedVector3Array([Vector3(190, 0, 120), Vector3(190, 0, 129), Vector3(210, 0, 129), Vector3(210, 0, 120)]))
	await walking("TerrainSeam", PackedVector3Array([Vector3(-70, 0, 300), Vector3(-50, 0, 300)]))
	# Physically push into each world edge from valid adjacent ground.
	for p in [Vector3(-498, 0, 400), Vector3(498, 0, 400), Vector3(400, 0, -498), Vector3(400, 0, 498)]:
		await place(p)
		actor.set_move_intent(Vector3(signf(p.x) if absf(p.x) > 497 else 0, 0, signf(p.z) if absf(p.z) > 497 else 0))
		await frames(90)
		expect(absf(actor.global_position.x) < 500 and absf(actor.global_position.z) < 500 and actor.is_on_floor(), "solid world bound retains walking body " + str(p))
		actor.set_move_intent(Vector3.ZERO)
	await camera_checks()
	var lever := area.get_node("Lever") as WorkTarget
	await place(lever.global_position + Vector3(0, -1, 1.2))
	expect(lever.begin(actor), "existing real M1 lever remains reachable and correctly wired")
	lever.advance(actor, 1.0)
	lever.cancel(actor)
	expect(lever.progress_seconds == 1.0 and not lever.is_complete, "M1 interaction progress survives cancel in new map")
	var report := {"complete": true, "success": failures == 0, "checks": checks, "failures": failures, "frames": frames_used, "walks": measurements}
	var output := "/tmp/false-world-map-walks.json"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output = argument.trim_prefix("--output=")
	var file := FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		expect(false, "write completion report")
	else:
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
	viewport.queue_free()
	await frames(4)
	print("Map foundation: %d checks, %d failures; complete=true" % [checks, failures])
	quit(0 if failures == 0 else 1)


func camera_checks() -> void:
	var rig := actor.get_node("CameraRig") as FollowCamera
	var camera := rig.camera
	var body := actor.get_node("Visual/Body") as MeshInstance3D
	var clear := true
	var framed := true
	var retracted := false
	var samples := 0
	var shape := BoxShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.exclude = [actor.get_rid()]
	for point in [Vector3(192.3, 0, 110.3), Vector3(193.9, 0, 112), MapLayout.point(-100, -260), MapLayout.point(-260, -260)]:
		await place(point)
		for pitch in [-65, -18, 0, 20]:
			rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
			for yaw in range(0, 360, 30):
				rig.rotation.y = deg_to_rad(yaw)
				await frames(2)
				var extent := camera.get_camera_projection().get_viewport_half_extents()
				var camera_box := AABB(camera.global_position, Vector3.ZERO)
				for x in [-extent.x, extent.x]:
					for y in [-extent.y, extent.y]:
						camera_box = camera_box.expand(camera.global_transform * Vector3(x, y, -camera.near))
				camera_box = camera_box.grow(0.02)
				shape.size = camera_box.size
				query.transform = Transform3D(Basis.IDENTITY, camera_box.get_center())
				clear = clear and actor.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
				var box := body.global_transform * body.get_aabb()
				clear = clear and camera.global_position.distance_to(camera.global_position.clamp(box.position, box.end)) >= 1.1
				var screen_min := Vector2(INF, INF)
				var screen_max := Vector2(-INF, -INF)
				for i in range(8):
					var pixel := camera.unproject_position(box.get_endpoint(i))
					screen_min = screen_min.min(pixel)
					screen_max = screen_max.max(pixel)
				framed = framed and camera.is_position_in_frustum(body.global_position) and body.is_visible_in_tree()
				framed = framed and screen_min.x >= 0 and screen_min.y >= 0 and screen_max.x <= 1280 and screen_max.y <= 720
				var fraction := (screen_max - screen_min) / Vector2(1280, 720)
				framed = framed and maxf(fraction.x, fraction.y) <= 0.8
				retracted = retracted or rig.spring.get_hit_length() < 1
				samples += 1
	expect(clear, "new corners and mountain slopes: camera origin/near-plane enclosure and self clearance (" + str(samples) + " orbits)")
	expect(framed and retracted, "new geometry: whole body framed <=80 percent, real wall retraction observed")
