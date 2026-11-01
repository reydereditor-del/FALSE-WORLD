extends SceneTree
## Geometric regression, not a graphical/framing or input-comfort playtest.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	root.size = Vector2i(1280, 720)
	call_deferred("_run")


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


func camera_bounds(camera: Camera3D) -> AABB:
	# Conservative enclosure of camera origin + near rectangle, with 2 cm clearance.
	var extent := camera.get_camera_projection().get_viewport_half_extents()
	var bounds := AABB(camera.global_position, Vector3.ZERO)
	for x in [-extent.x, extent.x]:
		for y in [-extent.y, extent.y]:
			bounds = bounds.expand(camera.global_transform * Vector3(x, y, -camera.near))
	return bounds.grow(0.02)


func _run() -> void:
	var world := load("res://scenes/prototype/m1_graybox.tscn").instantiate() as Node3D
	root.add_child(world)
	var actor := world.get_node("Character") as CharacterMotor
	actor.get_node("LocalController").set_physics_process(false)
	actor.get_node("LocalController").set_process_unhandled_input(false)
	var rig := actor.get_node("CameraRig") as FollowCamera
	var camera := rig.spring.get_node("Camera3D") as Camera3D
	var body := actor.get_node("Visual/Body") as MeshInstance3D
	var marker := actor.get_node("Visual/FacingMarker") as MeshInstance3D
	await frames(10)

	# Original reported case: character pressed against north wall, camera at front.
	actor.position = Vector3(0, 0, -11.14)
	rig.rotation.y = PI
	rig.pitch_pivot.rotation.x = deg_to_rad(-18.0)
	await frames(4)
	var character_bounds := body.global_transform * body.get_aabb()
	expect(not camera_bounds(camera).intersects(character_bounds),
		"front orbit against wall keeps camera and near plane outside character")

	# Actual M1 walls, corners and obstacle; both pitch limits and intermediate angles.
	var locations := [
		Vector3(0, 0, -11.14), Vector3(0, 0, 11.14),
		Vector3(-11.14, 0, 0), Vector3(11.14, 0, 0),
		Vector3(-11.14, 0, -11.14), Vector3(11.14, 0, 11.14),
		Vector3(0, 0, 1.36)
	]
	var overlaps: int = 0
	var wall_overlaps: int = 0
	var hidden: int = 0
	var out_of_frame: int = 0
	var samples: int = 0
	var walls: Array[AABB] = []
	for name in ["NorthWall", "SouthWall", "EastWall", "WestWall", "Obstacle", "Ground"]:
		var mesh := world.get_node(name + "/Mesh") as MeshInstance3D
		walls.append(mesh.global_transform * mesh.get_aabb())
	for location in locations:
		actor.position = location
		for pitch in [-65.0, -18.0, 0.0, 20.0]:
			rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
			for yaw in range(0, 360, 30):
				rig.rotation.y = deg_to_rad(float(yaw))
				await frames(2)
				var bounds := camera_bounds(camera)
				if bounds.intersects(body.global_transform * body.get_aabb()) or bounds.intersects(
					marker.global_transform * marker.get_aabb()):
					overlaps += 1
				for wall in walls:
					if bounds.intersects(wall):
						wall_overlaps += 1
				if not body.is_visible_in_tree() or not marker.is_visible_in_tree():
					hidden += 1
				if not camera.is_position_in_frustum(body.global_position):
					out_of_frame += 1
				samples += 1
	print("Orbit samples: %d; self overlaps: %d; geometry overlaps: %d" % [samples, overlaps, wall_overlaps])
	expect(overlaps == 0, "camera/near-plane clearance across walls, corners, obstacle and pitch limits")
	expect(wall_overlaps == 0, "camera/near plane remain outside solid yard geometry")
	expect(hidden == 0, "character visibility stays enabled in every sampled orbit")

	expect(out_of_frame == 0, "character center stays inside camera frustum during sampled retraction")

	# An obstructed ray must still retract, not enforce a minimum arm through a wall.
	actor.position = Vector3(5, 0, 10)
	rig.rotation.y = 0.0
	rig.pitch_pivot.rotation.x = deg_to_rad(20.0)
	await frames(4)
	expect(rig.spring.get_hit_length() < rig.spring.spring_length - 0.5,
		"wall collision still retracts spring arm")

	# Open-space small orbit commands should retain continuous motion and full radius.
	actor.position = Vector3(5, 0, 5)
	rig.pitch_pivot.rotation.x = deg_to_rad(-18.0)
	rig.rotation.y = 0.0
	await frames(4)
	var previous := camera.global_position
	var continuous := true
	for index in range(30):
		rig.orbit(Vector2(4, 0))
		await frames(2)
		var distance := camera.global_position.distance_to(previous)
		continuous = continuous and distance > 0.001 and distance < 0.1
		continuous = continuous and is_equal_approx(rig.spring.get_hit_length(), rig.spring.spring_length)
		previous = camera.global_position
	expect(continuous, "small unobstructed orbit steps remain continuous at full arm length")
	# Worst-case retraction must be safe even when the arm has no remaining length.
	var normal_length := rig.spring.spring_length
	rig.spring.spring_length = 0.0
	var collapsed_clear := true
	var collapsed_framed := true
	for pitch in [-65.0, -18.0, 0.0, 20.0]:
		rig.pitch_pivot.rotation.x = deg_to_rad(pitch)
		await frames(2)
		collapsed_framed = collapsed_framed and camera.is_position_in_frustum(body.global_position)
		collapsed_clear = collapsed_clear and not camera_bounds(camera).intersects(
			body.global_transform * body.get_aabb())
	expect(collapsed_clear, "fully retracted camera and near plane stay above the character")
	expect(collapsed_framed, "fully retracted camera still frames the character center")
	rig.spring.spring_length = normal_length
	world.queue_free()
	await frames(2)
	print("Camera regression: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
