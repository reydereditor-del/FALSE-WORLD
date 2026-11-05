class_name WorkerPresentation
extends Node3D
## Shared visible rig only. Reads actual body velocity; never supplies movement/AI state.

const MODEL := preload("res://assets/visual/models/worker.glb")
var animation_player: AnimationPlayer
var skeleton: Skeleton3D
var current_state: StringName = &"Idle"
var source_clip: StringName
var motor: CharacterMotor
var directional_clip_missing: bool = false
var licensed_walks_installed: bool = false
var _licensed_phase: float = 0.0


func _ready() -> void:
	motor = get_parent().get_parent() as CharacterMotor
	var model := MODEL.instantiate() as Node3D
	model.name = "WorkerModel"
	model.scale = Vector3.ONE * 1.2
	# Source faces +X in its Z-up rig; align source forward with motor's -Z.
	model.rotation.y = PI
	add_child(model)
	for mesh_node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh := mesh_node as MeshInstance3D
		var material := mesh.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
		material.vertex_color_use_as_albedo = true
		material.roughness = 0.88
		mesh.material_override = material
	animation_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	skeleton = model.find_child("Skeleton3D", true, false) as Skeleton3D
	assert(animation_player != null and skeleton != null)
	for name in animation_player.get_animation_list():
		if name != &"RESET":
			source_clip = name
			break
	assert(source_clip != &"")
	var walk := animation_player.get_animation(source_clip).duplicate(true) as Animation
	walk.loop_mode = Animation.LOOP_LINEAR
	var library := AnimationLibrary.new()
	library.add_animation(&"Walk", walk)
	animation_player.play(source_clip)
	animation_player.seek(0.0, true)
	animation_player.pause()
	# A walk contact frame is not a standing pose: reset the rig, then author
	# matching resting arms in world space, independent of imported bone axes.
	for index in range(skeleton.get_bone_count()):
		skeleton.reset_bone_pose(index)
	_rest_arms()
	var idle := Animation.new()
	idle.length = 3.0
	idle.loop_mode = Animation.LOOP_LINEAR
	var animation_root := animation_player.get_node(animation_player.root_node)
	var skeleton_path := animation_root.get_path_to(skeleton)
	for index in range(skeleton.get_bone_count()):
		var path := NodePath(String(skeleton_path) + ":" + String(skeleton.get_bone_name(index)))
		var position_track := idle.add_track(Animation.TYPE_POSITION_3D)
		idle.track_set_path(position_track, path)
		idle.position_track_insert_key(position_track, 0.0, skeleton.get_bone_pose_position(index))
		var rotation_track := idle.add_track(Animation.TYPE_ROTATION_3D)
		idle.track_set_path(rotation_track, path)
		var rotation := skeleton.get_bone_pose_rotation(index)
		idle.rotation_track_insert_key(rotation_track, 0.0, rotation)
		if index == 2:
			idle.rotation_track_insert_key(rotation_track, 1.5, rotation * Quaternion(Vector3.RIGHT, 0.012))
		idle.rotation_track_insert_key(rotation_track, 3.0, rotation)
	library.add_animation(&"Idle", idle)
	animation_player.add_animation_library(&"Presentation", library)
	animation_player.play(&"Presentation/Idle")
	licensed_walks_installed = LicensedWalks.add_library(animation_player)


func _rest_arms() -> void:
	var chains := [
		["Skeleton_arm_joint_L__4_", "Skeleton_arm_joint_L__3_", "Skeleton_arm_joint_L__2_"],
		["Skeleton_arm_joint_R", "Skeleton_arm_joint_R__2_", "Skeleton_arm_joint_R__3_"]]
	var left := skeleton.find_bone(chains[0][0])
	var right := skeleton.find_bone(chains[1][0])
	var side := (skeleton.get_bone_global_pose(left).origin - skeleton.get_bone_global_pose(right).origin).normalized()
	var down := (skeleton.global_basis.inverse() * Vector3.DOWN).normalized()
	for chain_index in range(2):
		var outward := side * (1.0 if chain_index == 0 else -1.0)
		for segment in range(2):
			var bone := skeleton.find_bone(chains[chain_index][segment])
			var child := skeleton.find_bone(chains[chain_index][segment + 1])
			var pose := skeleton.get_bone_global_pose(bone)
			var current := (skeleton.get_bone_global_pose(child).origin - pose.origin).normalized()
			var desired := (down + outward * (0.1 if segment == 0 else 0.03)).normalized()
			var basis := Basis(Quaternion(current, desired)) * pose.basis
			var parent := skeleton.get_bone_parent(bone)
			if parent >= 0:
				basis = skeleton.get_bone_global_pose(parent).basis.inverse() * basis
			skeleton.set_bone_pose_rotation(bone, basis.get_rotation_quaternion())


func _physics_process(_delta: float) -> void:
	var speed := Vector2(motor.velocity.x, motor.velocity.z).length()
	if licensed_walks_installed and motor.has_facing_intent:
		_step_licensed(speed)
		return
	# The acquired rig has only one forward walk. Never play that as a purported
	# backward/strafe clip. Human-only neutral fallback until compatible clips exist.
	var local_velocity: Vector3 = motor.get_node("Visual").global_basis.inverse() * motor.velocity
	directional_clip_missing = motor.has_facing_intent and speed > 0.12 and (
		local_velocity.z >= 0.0 or absf(local_velocity.x) > speed * 0.15)
	var desired: StringName = &"Walk" if speed > 0.12 else &"Idle"
	if directional_clip_missing:
		desired = &"Idle"
	if desired != current_state:
		current_state = desired
		animation_player.play(StringName("Presentation/" + String(desired)), 0.18)
	animation_player.speed_scale = clampf(speed / 2.5, 0.4, 1.6) if desired == &"Walk" else 1.0


func _step_licensed(speed: float) -> void:
	directional_clip_missing = false
	if speed <= 0.12:
		if current_state != &"Idle":
			var prior := animation_player.get_animation(animation_player.current_animation)
			_licensed_phase = animation_player.current_animation_position / prior.length
			current_state = &"Idle"
			animation_player.play(&"Presentation/Idle", 0.18)
		animation_player.speed_scale = 1.0
		return
	var local_velocity: Vector3 = motor.get_node("Visual").global_basis.inverse() * motor.velocity
	var clip_name := LicensedWalks.select_clip(local_velocity)
	var path := StringName("Licensed/" + String(clip_name))
	if animation_player.current_animation != path:
		if current_state != &"Idle":
			var prior := animation_player.get_animation(animation_player.current_animation)
			_licensed_phase = animation_player.current_animation_position / prior.length
		animation_player.play(path, 0.18)
		animation_player.seek(fposmod(_licensed_phase, 1.0) * animation_player.get_animation(path).length, true)
	current_state = &"Walk" if clip_name == &"run_forward" or clip_name == &"walk_forward" else clip_name
	var clip := animation_player.get_animation(path)
	animation_player.speed_scale = speed / float(clip.get_meta("nominal_speed"))
