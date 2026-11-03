extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ", label)
	if not ok:
		failures += 1
		push_error(label)
func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame
func fraction(camera: Camera3D, box: AABB) -> float:
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for i in range(8):
		var p := box.get_endpoint(i)
		if camera.is_position_behind(p): return INF
		var pixel := camera.unproject_position(p)
		low = low.min(pixel)
		high = high.max(pixel)
	if low.x < 0 or low.y < 0 or high.x > 1280 or high.y > 720: return INF
	var size := (high-low)/Vector2(1280,720)
	return maxf(size.x,size.y)
func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280,720)
	viewport.own_world_3d = true
	root.add_child(viewport)
	var world := load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D
	viewport.add_child(world)
	var area := world.get_node("LocalArea")
	area.set_physics_process(false)
	for c in area.controllers:
		c.set_physics_process(false)
		c.motor.set_move_intent(Vector3.ZERO)
	var actor := area.get_node("Character") as CharacterMotor
	actor.get_node("LocalController").set_physics_process(false)
	actor.global_position = Vector3(220,.1,140)
	await frames(20)
	expect(actor.facing_turn_speed > 0 and actor.move_speed == 4 and actor.gravity == 18, "Stage4 human opts into bounded turning without movement changes")
	var bounded := true
	for direction in [Vector3.RIGHT,Vector3.LEFT,Vector3.BACK,Vector3.FORWARD]:
		actor.set_move_intent(direction)
		for i in range(24):
			var before: float = actor.get_node("Visual").rotation.y
			await frames(1)
			bounded = bounded and absf(angle_difference(before,actor.get_node("Visual").rotation.y)) <= 3.5/60 + .002
	expect(bounded,"left/right/back reversals rotate through bounded intermediate angles")
	actor.set_move_intent(Vector3.ZERO)
	await frames(30)
	var symmetric := true
	var down := true
	for p: WorkerPresentation in world.get_node("StationArt").presentations:
		var s := p.skeleton
		var arms := [["Skeleton_arm_joint_L__4_","Skeleton_arm_joint_L__3_","Skeleton_arm_joint_L__2_"],["Skeleton_arm_joint_R","Skeleton_arm_joint_R__2_","Skeleton_arm_joint_R__3_"]]
		var forward: Array[float] = []
		for arm in arms:
			var shoulder := s.global_transform*s.get_bone_global_pose(s.find_bone(arm[0])).origin
			var elbow := s.global_transform*s.get_bone_global_pose(s.find_bone(arm[1])).origin
			var wrist := s.global_transform*s.get_bone_global_pose(s.find_bone(arm[2])).origin
			down = down and (elbow-shoulder).normalized().dot(Vector3.DOWN) > .95 and wrist.y < elbow.y
			var local: Vector3 = p.motor.get_node("Visual").global_basis.inverse()*(wrist-shoulder)
			forward.append(local.z)
		symmetric = symmetric and absf(forward[0]-forward[1]) < .03
	expect(down and symmetric,"all four actual idle skeletons have downward, symmetric arms rather than frozen opposite walk swings")
	var presentation := actor.get_node("Visual/WorkerPresentation") as WorkerPresentation
	var previous := presentation.skeleton.get_bone_pose_rotation(5)
	var blended := true
	for moving in [true,false]:
		actor.set_move_intent(Vector3.RIGHT if moving else Vector3.ZERO)
		for i in range(30):
			await frames(1)
			var pose := presentation.skeleton.get_bone_pose_rotation(5)
			blended = blended and previous.angle_to(pose) < .5
			previous = pose
	expect(blended and presentation.current_state == &"Idle", "actual walk/idle arm transitions blend over frames")
	var rig := actor.get_node("CameraRig") as FollowCamera
	expect(rig.minimum_pitch_degrees == -80 and rig.maximum_pitch_degrees == 20,"Stage4 downward range grows while upward limit stays unchanged")
	var shape := BoxShape3D.new()
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.exclude = [actor.get_rid()]
	var clear := true
	var framed := true
	var samples := 0
	for position_value in [Vector3(220,0,140),Vector3(193.9,0,112),Vector3(202.6,0,126)]:
		actor.global_position = position_value + Vector3.UP*.1
		actor.velocity = Vector3.ZERO
		await frames(20)
		for pitch in [-80,-75,-65,20]:
			rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
			for yaw in range(0,360,30):
				rig.rotation.y = deg_to_rad(yaw)
				await frames(2)
				var camera := rig.camera
				var ext := camera.get_camera_projection().get_viewport_half_extents()
				var box := AABB(camera.global_position,Vector3.ZERO)
				for x in [-ext.x,ext.x]:
					for y in [-ext.y,ext.y]: box = box.expand(camera.global_transform*Vector3(x,y,-camera.near))
				box = box.grow(.02)
				shape.size = box.size
				query.transform = Transform3D(Basis.IDENTITY,box.get_center())
				clear = clear and actor.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()
				var mesh := actor.get_node("Visual/Body") as MeshInstance3D
				var body := mesh.global_transform*mesh.get_aabb()
				clear = clear and camera.global_position.distance_to(camera.global_position.clamp(body.position,body.end)) >= 1.1
				framed = framed and fraction(camera,body) <= .8
				samples += 1
	expect(clear and samples == 144,"144 Stage4 open/door/corner orbits retain near-plane/world and character clearance including new endpoint")
	expect(framed,"existing whole-body <=80 percent framing criterion preserved at deeper angles")
	viewport.queue_free()
	await frames(4)
	print("Character fixes: %d checks, %d failures; complete=true" % [checks,failures])
	quit(0 if failures == 0 else 1)
