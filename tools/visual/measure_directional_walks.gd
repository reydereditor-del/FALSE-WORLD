extends SceneTree
## Measure real planted-ankle motion on the current rig, independent of clip metadata.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var model := load("res://assets/visual/models/worker.glb").instantiate() as Node3D
	model.scale=Vector3.ONE*1.2;model.rotation.y=PI;root.add_child(model)
	var player := model.find_child("AnimationPlayer",true,false) as AnimationPlayer
	var skeleton := model.find_child("Skeleton3D",true,false) as Skeleton3D
	var library := AnimationLibrary.new()
	for name in ["backward_walk","strafe_left","strafe_right"]:
		library.add_animation(name,load("res://assets/visual/animations/"+name+".tres"))
	player.add_animation_library("Measure",library)
	for name in library.get_animation_list():
		var clip := library.get_animation(name)
		player.play("Measure/"+name,0);player.advance(0);player.pause()
		var ankle := 17 if name=="strafe_right" else 13
		player.seek(clip.length*.1,true)
		var first := skeleton.global_transform*skeleton.get_bone_global_pose(ankle).origin
		player.seek(clip.length*.5,true)
		var last := skeleton.global_transform*skeleton.get_bone_global_pose(ankle).origin
		var travel := last-first
		var horizontal := Vector2(travel.x,travel.z).length()
		print(name,": planted ankle travel=",horizontal,"m over ",clip.length*.4,"s; intended speed=",horizontal/(clip.length*.4),"m/s; vertical drift=",travel.y)
	model.queue_free();await process_frame;quit()
