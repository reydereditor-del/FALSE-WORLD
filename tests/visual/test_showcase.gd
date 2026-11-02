extends SceneTree
## New-scene integration: imported rigs, real movement, materials, camera and navigation.

var checks := 0
var failures := 0
var frames_used := 0
var started := 0
var world: Node3D
var area: Node3D
var actor: CharacterMotor


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
	for i in range(count):
		frames_used += 1
		if frames_used > 6500 or Time.get_ticks_msec() - started > 90000:
			push_error("Showcase incomplete: finite frame/wall budget exhausted")
			quit(2)
			return
		await physics_frame
		await process_frame


func place(point: Vector3) -> void:
	actor.global_position = point + Vector3.UP * 0.1
	actor.velocity = Vector3.ZERO
	actor.set_move_intent(Vector3.ZERO)
	await frames(20)


func walk(label: String, points: PackedVector3Array) -> void:
	await place(points[0])
	var reached := true
	var max_air := 0
	var air := 0
	var max_step := 0.0
	for i in range(1, points.size()):
		var arrived := false
		for tick in range(600):
			var offset := points[i] - actor.global_position
			offset.y = 0
			if offset.length() < 0.22:
				arrived = true
				break
			var previous := actor.global_position
			actor.set_move_intent(offset.normalized())
			await frames(1)
			max_step = maxf(max_step, actor.global_position.distance_to(previous))
			air = 0 if actor.is_on_floor() else air + 1
			max_air = maxi(max_air, air)
		reached = reached and arrived
		if not arrived:
			print(label, " stuck at ", actor.global_position, " goal ", points[i])
	actor.set_move_intent(Vector3.ZERO)
	expect(reached and max_air <= 4 and max_step < 0.08, label + ": actual no-jump walking, supported and unaccelerated")


func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.own_world_3d = true
	root.add_child(viewport)
	world = load("res://scenes/visual/visual_vertical_slice.tscn").instantiate()
	viewport.add_child(world)
	area = world.get_node("LocalArea")
	actor = area.get_node("Character")
	actor.get_node("LocalController").set_physics_process(false)
	await frames(20)
	var art := world.get_node("StationArt")
	expect(art.presentations.size() == 4 and area.actors.size() == 4, "one human and three AI receive the same real worker asset")
	var shape: CapsuleShape3D = actor.get_node("CollisionShape3D").shape
	expect(is_equal_approx(shape.radius, 0.35) and is_equal_approx(shape.height, 1.8) and actor.move_speed == 4.0 and actor.gravity == 18.0,
		"original body/capsule/motor physics are unchanged")
	expect(actor.get_node("LocalController").motor == actor and actor.get_node("Interactor").target == area.get_node("Lever"),
		"original input and real interaction references preserved")
	var body := actor.get_node("Visual/WorkerPresentation") as WorkerPresentation
	for presentation: WorkerPresentation in art.presentations:
		expect(presentation.skeleton.get_bone_count() == 19 and presentation.source_clip != &"" and
			presentation.animation_player.has_animation(&"Presentation/Walk") and presentation.animation_player.has_animation(&"Presentation/Idle"),
			"actual imported 19-bone skin and both animation clips: " + String(presentation.motor.name))
	var first_pose := body.skeleton.get_bone_pose_rotation(2)
	await frames(45)
	expect(body.current_state == &"Idle" and body.animation_player.is_playing() and
		first_pose.angle_to(body.skeleton.get_bone_pose_rotation(2)) > 0.001,
		"stationary humanoid plays real original breathing Idle; pose changes")
	for name in ["concrete", "steel", "gravel"]:
		var material := load("res://assets/visual/materials/" + name + ".tres") as StandardMaterial3D
		expect(material.albedo_texture.get_width() == 1024 and material.normal_enabled and
			material.normal_texture.get_width() == 1024 and material.roughness_texture.get_width() == 1024,
			name + ": actual imported 1K albedo/normal/roughness maps, no missing resources")
	expect(world.get_node("StationQuarter/Storehouse/West/Mesh").material_override != null,
		"real wall surface uses new textured material")
	expect(art.get_node("BoomBox").get_child_count() > 0 and art.get_node("Lantern").get_child_count() > 0,
		"real licensed GLB prop scenes imported and instantiated")
	expect((world.get_node("Environment").environment as Environment).fog_enabled and world.get_node("Sun").shadow_enabled,
		"showcase uses overcast environment, restrained non-volumetric fog and shadows")
	var starts: Array[Vector3] = []
	for controller in area.controllers:
		starts.append(controller.motor.global_position)
	for tick in range(1200):
		await frames(1)
	var moved := 0
	for i in range(3):
		if area.controllers[i].motor.global_position.distance_to(starts[i]) > 1:
			moved += 1
	expect(moved == 3 and area.max_sensors_per_tick == 1, "all three actual AI move under unchanged staggered scheduling")
	var map: RID = area.controllers[0].navigator.get_navigation_map()
	var reachable := NavigationServer3D.map_get_iteration_id(map) > 0
	for site in area.sites:
		var near := NavigationServer3D.map_get_closest_point(map, site.position)
		var path := NavigationServer3D.map_get_path(map, Vector3(220, 0, 140), near, true)
		reachable = reachable and near.distance_to(site.position) < 0.75 and not path.is_empty()
		if not path.is_empty():
			reachable = reachable and path[-1].distance_to(near) < 0.5
	expect(reachable, "separate art-collider bake is synchronized and all ten old authored sites stay reachable")
	area.set_physics_process(false)
	for controller in area.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	await place(Vector3(200, 0, 135))
	actor.set_move_intent(Vector3.FORWARD)
	await frames(20)
	var walked_pose := body.skeleton.get_bone_pose_rotation(12)
	await frames(20)
	expect(body.current_state == &"Walk" and body.animation_player.is_playing() and
		walked_pose.angle_to(body.skeleton.get_bone_pose_rotation(12)) > 0.005,
		"real velocity switches to imported Walk and animated leg actually changes")
	actor.set_move_intent(Vector3.ZERO)
	await frames(25)
	expect(body.current_state == &"Idle", "stopping switches the real rig back to Idle")
	await walk("Both storehouse doors", PackedVector3Array([Vector3(200, 0, 133), Vector3(200, 0, 118), Vector3(200, 0, 107)]))
	await walk("Outside corner", PackedVector3Array([Vector3(190, 0, 120), Vector3(190, 0, 129), Vector3(210, 0, 129), Vector3(210, 0, 120)]))
	await place(Vector3(211.2, 0, 133.5))
	actor.set_move_intent(Vector3.RIGHT)
	await frames(45)
	expect(actor.global_position.x < 211.9, "new drum has an effective physical collider, not walk-through clutter")
	actor.set_move_intent(Vector3.ZERO)
	await place(Vector3(216, 0, 159.2))
	var lever := area.get_node("Lever") as WorkTarget
	expect(lever.begin(actor), "existing lever outside art area remains physically reachable")
	lever.advance(actor, 1.0)
	lever.cancel(actor)
	expect(lever.progress_seconds == 1.0 and not lever.is_complete, "real interaction cancel keeps partial progress")
	var rig := actor.get_node("CameraRig") as FollowCamera
	var camera := rig.camera
	var camera_safe := true
	var query := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.14
	query.shape = sphere
	query.exclude = [actor.get_rid()]
	for position_value in [Vector3(193.9, 0, 112), Vector3(202.6, 0, 126)]:
		await place(position_value)
		for pitch in [-65, -18, 20]:
			rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
			for yaw in range(0, 360, 60):
				rig.rotation.y = deg_to_rad(yaw)
				await frames(2)
				query.transform = Transform3D(Basis.IDENTITY, camera.global_position)
				camera_safe = camera_safe and actor.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()
				camera_safe = camera_safe and camera.is_position_in_frustum(actor.global_position + Vector3.UP * 0.9)
	expect(camera_safe, "36 new-art corner camera poses preserve collision clearance and focus framing")
	expect(not area.get_node("AIDebugOverlay").enabled, "developer-only diagnostics remain off by default")
	viewport.queue_free()
	await frames(4)
	print("Visual slice: %d checks, %d failures; complete=true" % [checks, failures])
	quit(0 if failures == 0 else 1)
