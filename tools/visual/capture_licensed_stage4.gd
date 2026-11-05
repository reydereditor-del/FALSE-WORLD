extends SceneTree
## Actual Stage 4 composition and Input actions; review camera only for readable footwork.
var output:="/tmp/licensed-stage4"
var use_game_camera:=false
var frame_count:=480
func _initialize()->void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
		if arg=="--game-camera":use_game_camera=true
		if arg.begins_with("--frames="):frame_count=arg.trim_prefix("--frames=").to_int()
	call_deferred("run")
func release()->void:
	for action in ["move_forward","move_back","move_left","move_right"]:Input.action_release(action)
func run()->void:
	root.size=Vector2i(640,480)
	var world:=load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D;root.add_child(world)
	var area:=world.get_node("LocalArea")
	var actor:=area.get_node("Character") as CharacterMotor
	var rig:=actor.get_node("CameraRig") as FollowCamera
	var skin:=actor.get_node("Visual/WorkerPresentation") as WorkerPresentation
	if not skin.licensed_walks_installed:
		push_error("Install the two user-licensed ZIPs before recording");quit(2);return
	if not use_game_camera:actor.global_position=Vector3(270,.1,155)
	actor.velocity=Vector3.ZERO
	var review:=Camera3D.new();review.far=80;review.projection=Camera3D.PROJECTION_ORTHOGONAL;review.size=2.4;world.add_child(review)
	if not use_game_camera:review.current=true
	DirAccess.make_dir_recursive_absolute(output)
	var trace:Array=[]
	var names:=["Idle","Forward 4 m/s","Backward 1.6 m/s","Left 1.6 m/s","Right 1.6 m/s","Forward-right diagonal","Back-left diagonal","Forward while camera turns","Stop"]
	var actions:=[[],["move_forward"],["move_back"],["move_left"],["move_right"],["move_forward","move_right"],["move_back","move_left"],["move_forward"],[]]
	var canvas:=CanvasLayer.new();world.add_child(canvas);var label:=Label.new();label.position=Vector2(12,12);canvas.add_child(label)
	for frame in range(frame_count):
		var t:=float(frame)/30
		var stage:=0 if t<1 else (1 if t<3 else (2 if t<5 else (3 if t<7 else (4 if t<9 else (5 if t<11 else (6 if t<13 else (7 if t<15 else 8)))))))
		release()
		actor.get_node("LocalController").set("_controls_active",true)
		for action in actions[stage]:Input.action_press(action)
		if stage==7:rig.rotation.y=minf((t-13)/1.0,1)*PI/2
		await physics_frame;await process_frame
		if not use_game_camera:
			var offset:=Vector3(2.3,1.8,-3.1) if t<7 or t>=11 else Vector3(3,1.5,.3)
			review.global_position=actor.global_position+actor.get_node("Visual").global_basis*offset
			review.look_at(actor.global_position+Vector3.UP*.8)
		label.text="Actual Stage 4 + real Input actions\n%s | %.2f m/s | %s"%[names[stage],Vector2(actor.velocity.x,actor.velocity.z).length(),skin.animation_player.current_animation]
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("%04d.png"%frame))
		trace.append({"frame":frame,"stage":names[stage],"position":actor.global_position,"velocity":actor.velocity,"clip":skin.animation_player.current_animation,"facing":actor.get_node("Visual").rotation.y})
	release()
	var f:=FileAccess.open(output.path_join("trace.json"),FileAccess.WRITE);f.store_string(JSON.stringify(trace,"  "));f.close()
	world.queue_free();await process_frame
	print("Licensed Stage 4 capture: ",frame_count," frames; complete=true; ",output)
	quit()
