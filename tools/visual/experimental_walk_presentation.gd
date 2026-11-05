extends WorkerPresentation
## Preview-only blend of existing clips. No asset creation or gameplay dependency.
## Forward-diagonal contact quality is unaccepted; do not use in production.
## Distances/cycle: authored back .7333, side .4667; imported forward contact
## median measured ~1.73 m/cycle. The 5.0 forward value preserves its existing
## 2-second clip with speed_scale=speed/2.5 for pure forward movement.
var clips: Array[Animation] = []
var mappings: Array[Array] = []
var idle_pose: Array[Transform3D] = []
var blend_weights := Vector4(0,0,0,0)
var phase := 0.0
var walk_weight := 0.0

func _ready() -> void:
	super()
	process_physics_priority=10
	animation_player.stop(true)
	clips.append(animation_player.get_animation("Presentation/Walk"))
	for name in ["backward_walk","strafe_left","strafe_right"]:
		clips.append(load("res://assets/visual/animations/"+name+".tres"))
	for i in range(19):idle_pose.append(Transform3D(Basis(skeleton.get_bone_pose_rotation(i)),skeleton.get_bone_pose_position(i)))
	for clip in clips:
		var mapping: Array = []
		for track in range(clip.get_track_count()):
			var bone := skeleton.find_bone(clip.track_get_path(track).get_subname(0))
			mapping.append(bone)
		mappings.append(mapping)

func sample(index: int, at: float) -> Array[Transform3D]:
	var poses: Array[Transform3D] = []
	for i in range(19):poses.append(skeleton.get_bone_rest(i))
	var clip := clips[index]
	for track in range(clip.get_track_count()):
		var bone: int=mappings[index][track]
		if bone<0:continue
		if clip.track_get_type(track)==Animation.TYPE_POSITION_3D:
			poses[bone].origin=clip.position_track_interpolate(track,at)
		elif clip.track_get_type(track)==Animation.TYPE_ROTATION_3D:
			poses[bone].basis=Basis(clip.rotation_track_interpolate(track,at))
	return poses

func _physics_process(delta: float) -> void:
	if clips.is_empty():return
	var local:Vector3=motor.get_node("Visual").global_basis.inverse()*motor.velocity
	local.y=0
	var speed:=local.length()
	var rates:=Vector4(maxf(-local.z,0)/1.73,maxf(local.z,0)/.7333333333,maxf(-local.x,0)/.4666666667,maxf(local.x,0)/.4666666667)
	# Preserve original forward clip cadence at 4 m/s; progressively use its
	# planted-foot scale for diagonals at much lower speed.
	var lateral_fraction:=absf(local.x)/maxf(speed,.001)
	var forward_distance:=lerpf(5.0,1.73,clampf(lateral_fraction/.5,0,1))
	rates.x=maxf(-local.z,0)/forward_distance
	var sum:=rates.x+rates.y+rates.z+rates.w
	var target:=rates/sum if sum>.01 else blend_weights
	var smooth:=1.0-exp(-delta/.10)
	blend_weights=blend_weights.lerp(target,smooth)
	walk_weight=move_toward(walk_weight,1.0 if speed>.08 else 0.0,delta/.18)
	phase=fposmod(phase+sum*delta,1.0)
	var poses: Array[Array] = []
	for i in range(4):
		# Align left-foot contact phase before blending; right strafe's loop starts
		# on the opposite foot in the original authored resource.
		var offset:=.5 if i==0 or i==3 else 0.0
		poses.append(sample(i,fposmod(phase+offset,1.0)*clips[i].length))
	for bone in range(19):
		var position:=Vector3.ZERO
		var rotation:=Quaternion.IDENTITY
		var accumulated:=0.0
		for i in range(4):
			var weight:float=blend_weights[i]
			if weight<.00001:continue
			var pose:Transform3D=poses[i][bone]
			position+=pose.origin*weight
			rotation=pose.basis.get_rotation_quaternion() if accumulated==0 else rotation.slerp(pose.basis.get_rotation_quaternion(),weight/(accumulated+weight))
			accumulated+=weight
		if accumulated<.001:position=idle_pose[bone].origin;rotation=idle_pose[bone].basis.get_rotation_quaternion()
		skeleton.set_bone_pose_position(bone,idle_pose[bone].origin.lerp(position,walk_weight))
		skeleton.set_bone_pose_rotation(bone,idle_pose[bone].basis.get_rotation_quaternion().slerp(rotation,walk_weight))
