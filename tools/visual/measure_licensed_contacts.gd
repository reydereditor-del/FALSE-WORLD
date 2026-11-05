extends SceneTree
## Contact diagnostics on the actual Stage 4 body; not a skinned-sole or Windows quality proof.
var output := "user://licensed_contact_metrics.json"
func _initialize()->void:call_deferred("run")
func frames(n:int)->void:
	for i in range(n):await physics_frame;await process_frame
func run()->void:
	if not LicensedWalks.installed():push_error("Install the licensed archives before contact diagnostics");quit(2);return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
	var passed:=true
	var world:=load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D;root.add_child(world)
	var area:=world.get_node("LocalArea");area.set_physics_process(false)
	for c in area.controllers:c.set_physics_process(false);c.motor.set_move_intent(Vector3.ZERO)
	var actor:=area.get_node("Character") as CharacterMotor
	actor.get_node("LocalController").set_physics_process(false)
	actor.directional_speeds_enabled=true;actor.set_facing_intent(Vector3.FORWARD)
	var skin:=actor.get_node("Visual/WorkerPresentation") as WorkerPresentation
	var result:Array=[]
	for direction in [Vector3.FORWARD,Vector3.BACK,Vector3.LEFT,Vector3.RIGHT,Vector3(1,0,-1).normalized(),Vector3(-1,0,1).normalized()]:
		actor.global_position=Vector3(270,.1,155);actor.velocity=Vector3.ZERO;actor.get_node("Visual").rotation.y=0;actor.set_move_intent(direction)
		await frames(45)
		var samples:Array=[]
		for tick in range(150):
			await frames(1)
			var a:=skin.skeleton.global_transform*skin.skeleton.get_bone_global_pose(13).origin
			var b:=skin.skeleton.global_transform*skin.skeleton.get_bone_global_pose(17).origin
			samples.append([a,b])
		var minimums:=[INF,INF]
		for sample in samples:
			for side in range(2):minimums[side]=minf(minimums[side],sample[side].y)
		var drift:Array[float]=[];var along:Array[float]=[]
		for i in range(1,samples.size()):
			for side in range(2):
				var a:Vector3=samples[i-1][side];var b:Vector3=samples[i][side]
				if maxf(a.y,b.y)>minimums[side]+.015 or absf(b.y-a.y)*60>.05:continue
				var velocity:Vector3=(b-a)*60
				drift.append(Vector2(velocity.x,velocity.z).length());along.append(velocity.dot(direction))
		var sum:=0.0;var proj:=0.0
		for value in drift:sum+=value
		for value in along:proj+=value
		var clip:=skin.animation_player.get_animation(skin.animation_player.current_animation)
		var row:={"direction":direction,"clip":skin.animation_player.current_animation,"samples":drift.size(),"mean_ankle_world_drift":sum/maxi(1,drift.size()),"mean_directional_drift":proj/maxi(1,along.size()),"nominal":clip.get_meta("nominal_speed"),"playback":skin.animation_player.speed_scale}
		result.append(row);print(row)
		passed=passed and drift.size()>=8 and float(row.mean_ankle_world_drift)<.05
	var f:=FileAccess.open(output,FileAccess.WRITE);f.store_string(JSON.stringify(result,"  "));f.close()
	world.queue_free();await frames(2)
	print("Licensed contact gates: 6 sampled directions; passed=",passed)
	quit(0 if passed else 1)
