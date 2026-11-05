extends SceneTree
## Offline, deterministic pose baking on the unchanged worker rig. No runtime IK.
## Run: godot --headless --path . --script res://tools/visual/author_directional_walks.gd
const MODEL = preload("res://assets/visual/models/worker.glb")
const OUTPUT := "res://assets/visual/animations/"
const PERIOD := 0.9
const STANCE := 0.60
const SAMPLES := 90
var rig: Skeleton3D
var rest: Array[Transform3D] = []
var model: Node3D
var frame: Transform3D

func _initialize() -> void: call_deferred("run")

func point(bone: int) -> Vector3:
	return frame * rig.get_bone_global_pose(bone).origin

func orient(bone: int, desired: Basis) -> void:
	var parent := rig.get_bone_parent(bone)
	var parent_basis := frame.basis
	if parent >= 0: parent_basis = (frame * rig.get_bone_global_pose(parent)).basis
	rig.set_bone_pose_rotation(bone, (parent_basis.inverse() * desired).orthonormalized().get_rotation_quaternion())

func aim(bone: int, child: int, target: Vector3) -> void:
	var origin := point(bone)
	var from := (point(child) - origin).normalized()
	var to := (target - origin).normalized()
	var basis := (frame * rig.get_bone_global_pose(bone)).basis
	orient(bone, Basis(Quaternion(from, to)) * basis)

func leg(hip: int, knee: int, ankle: int, toe: int, target: Vector3, roll: float) -> void:
	var origin := point(hip)
	var upper := origin.distance_to(point(knee))
	var lower := point(knee).distance_to(point(ankle))
	var line := target - origin
	var distance := clampf(line.length(), 0.03, upper + lower - 0.002)
	var axis := line.normalized()
	# Knees bend forward in the character frame, independently of bone roll.
	var pole := Vector3.FORWARD
	var bend := (pole - axis * pole.dot(axis)).normalized()
	var along := (upper * upper - lower * lower + distance * distance) / (2.0 * distance)
	var height := sqrt(maxf(upper * upper - along * along, 0.0))
	var knee_target := origin + axis * along + bend * height
	aim(hip, knee, knee_target)
	aim(knee, ankle, target)
	# Keep soles in the reference standing orientation; roll only on swing/toe-off.
	orient(ankle, Basis(Vector3.RIGHT, roll) * rest[ankle].basis)
	orient(toe, Basis(Vector3.RIGHT, roll * 0.25) * rest[toe].basis)

func arm(shoulder: int, elbow: int, wrist: int, side: float, swing: float) -> void:
	var origin := point(shoulder)
	var upper := (Vector3.DOWN + Vector3(side * 0.10, 0, swing)).normalized()
	aim(shoulder, elbow, origin + upper)
	var forearm := (Vector3.DOWN + Vector3(side * 0.03, 0, swing - 0.20)).normalized()
	aim(elbow, wrist, point(elbow) + forearm)

func pose(phase: float, direction: Vector3) -> void:
	for i in range(rig.get_bone_count()): rig.reset_bone_pose(i)
	var lateral := absf(direction.x) > 0.5
	var sway := 0.012 * sin(TAU * phase)
	var pelvis := rest[0].origin + Vector3(sway, -0.055 + 0.008 * cos(TAU * phase * 2.0), 0)
	rig.set_bone_pose_position(0, frame.affine_inverse() * pelvis)
	orient(0, Basis(Vector3.FORWARD, 0.018 * sin(TAU * phase)) * rest[0].basis)
	orient(2, Basis(Vector3.UP, 0.025 * sin(TAU * phase)) * rest[2].basis)
	for side_index in range(2):
		var phase_offset := 0.0 if side_index == 0 else 0.5
		# Leading leg opens the strafe; trailing leg follows without crossing.
		if lateral and direction.x > 0: phase_offset += 0.5
		var q := fposmod(phase + phase_offset, 1.0)
		var travel: float
		var lift := 0.0
		var roll := 0.0
		var half_stride := 0.22 if not lateral else 0.14
		if q < STANCE:
			# Constant backward foot speed during ground contact, no horizontal root motion.
			travel = half_stride * (1.0 - 2.0 * q / STANCE)
			roll = -0.06 * pow(q / STANCE, 6.0)
		else:
			var u := (q - STANCE) / (1.0 - STANCE)
			# Hermite swing matches the stance derivative at both contacts.
			var slope := -(1.0 - STANCE) / STANCE
			var h := (-2*u*u*u + 3*u*u) + (2*u*u*u - 3*u*u + u) * slope
			travel = lerpf(-half_stride, half_stride, h)
			lift = 0.065 * pow(sin(PI * u), 2.0)
			roll = -0.06 * pow(1.0 - u, 2.0) + 0.18 * sin(TAU * u) * sin(PI * u)
		var ankle := 13 if side_index == 0 else 17
		var target := rest[ankle].origin
		if lateral: target.x = -0.18 if side_index == 0 else 0.18
		target += direction * travel + Vector3.UP * lift
		leg(11 if side_index == 0 else 15, 12 if side_index == 0 else 16,
			ankle, 14 if side_index == 0 else 18, target, roll)
	var swing := 0.13 * sin(TAU * phase)
	arm(5,6,7,-1.0,swing)
	arm(8,9,10,1.0,-swing)

func bake(label: String, direction: Vector3) -> void:
	var animation := Animation.new()
	animation.length = PERIOD
	animation.loop_mode = Animation.LOOP_LINEAR
	animation.resource_name = label
	animation.set_meta("author", "FALSE WORLD local authoring")
	animation.set_meta("distance_per_cycle", (0.44 if direction.z > 0 else 0.28) / STANCE)
	animation.set_meta("source", "tools/visual/author_directional_walks.gd; existing worker skeleton")
	for i in range(rig.get_bone_count()):
		var path := NodePath("Z_UP/Armature/Skeleton3D:" + String(rig.get_bone_name(i)))
		var position := animation.add_track(Animation.TYPE_POSITION_3D)
		animation.track_set_path(position, path)
		var rotation := animation.add_track(Animation.TYPE_ROTATION_3D)
		animation.track_set_path(rotation, path)
	for sample in range(SAMPLES + 1):
		var phase := float(sample) / SAMPLES
		pose(phase if sample < SAMPLES else 0.0, direction)
		for i in range(rig.get_bone_count()):
			animation.position_track_insert_key(i*2, phase*PERIOD, rig.get_bone_pose_position(i))
			animation.rotation_track_insert_key(i*2+1, phase*PERIOD, rig.get_bone_pose_rotation(i))
	var result := ResourceSaver.save(animation, OUTPUT + label.to_snake_case() + ".tres")
	assert(result == OK)
	print("Authored ",label," period=",PERIOD," distance/cycle=",animation.get_meta("distance_per_cycle"))

func run() -> void:
	model = MODEL.instantiate()
	model.scale = Vector3.ONE * 1.2
	model.rotation.y = PI
	root.add_child(model)
	var player := model.find_child("AnimationPlayer",true,false) as AnimationPlayer
	player.stop()
	rig = model.find_child("Skeleton3D",true,false) as Skeleton3D
	frame = rig.global_transform
	for i in range(rig.get_bone_count()): rig.reset_bone_pose(i)
	for i in range(rig.get_bone_count()): rest.append(frame * rig.get_bone_global_pose(i))
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	bake("BackwardWalk", Vector3.BACK)
	bake("StrafeLeft", Vector3.LEFT)
	bake("StrafeRight", Vector3.RIGHT)
	model.queue_free()
	quit()
