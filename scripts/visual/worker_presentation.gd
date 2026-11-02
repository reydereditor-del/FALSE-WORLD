class_name WorkerPresentation
extends Node3D
## Shared visible rig only. Reads actual body velocity; never supplies movement/AI state.

const MODEL := preload("res://assets/visual/models/worker.glb")
var animation_player: AnimationPlayer
var skeleton: Skeleton3D
var current_state: StringName = &"Idle"
var source_clip: StringName
var motor: CharacterMotor


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
	# Original idle: source arm posture, straight resting legs, restrained chest breathing.
	for index in range(skeleton.get_bone_count()):
		if String(skeleton.get_bone_name(index)).begins_with("leg_"):
			skeleton.reset_bone_pose(index)
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


func _physics_process(_delta: float) -> void:
	var speed := Vector2(motor.velocity.x, motor.velocity.z).length()
	var desired: StringName = &"Walk" if speed > 0.12 else &"Idle"
	if desired != current_state:
		current_state = desired
		animation_player.play(StringName("Presentation/" + String(desired)), 0.18)
	animation_player.speed_scale = clampf(speed / 2.5, 0.4, 1.6) if desired == &"Walk" else 1.0
