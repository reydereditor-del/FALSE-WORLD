extends SceneTree
## Verifies experiment mechanics. It does NOT accept the known diagonal visual defect.
var checks:=0
var failures:=0
func _initialize()->void:call_deferred("run")
func expect(ok:bool,label:String)->void:
	checks+=1;print("PASS: " if ok else "FAIL: ",label)
	if not ok:failures+=1;push_error(label)
func run()->void:
	var experiment:=load("res://scenes/preview/moving_walk_experiment.tscn").instantiate() as Control
	experiment.auto_finish=false
	root.add_child(experiment)
	var profiles:Array=experiment.PROFILES
	var seen:Array=[];var correct:Array=[]
	var previous:Array[Vector3]=[]
	var yaws:Array[float]=[]
	var spaces:Array[RID]=[]
	for actor:CharacterMotor in experiment.actors:
		seen.append([0,0,0,0,0,0,0,0,0,0]);correct.append([true,true,true,true,true,true,true,true,true,true])
		previous.append(actor.position);yaws.append(actor.get_node("Visual").rotation.y)
		spaces.append(actor.get_world_3d().space)
	expect(spaces[0]!=spaces[1] and spaces[0]!=spaces[2] and spaces[1]!=spaces[2],"comparison profiles have independent physics spaces")
	var used:=0;var prior_time:=0.0
	var bounded:=true;var facing:=true;var rig_ok:=true
	var start:=Time.get_ticks_msec()
	while not experiment.finished and used<1100 and Time.get_ticks_msec()-start<45000:
		await physics_frame;await process_frame
		used+=1
		var t:float=experiment.elapsed
		var delta:=t-prior_time
		var current:int=experiment.stage(t)
		var margins:=[0.0,1.5,3.5,4.5,6.5,8.5,9.5,11.5,13.5,16.0,17.0]
		for index in range(3):
			var actor:CharacterMotor=experiment.actors[index]
			var speed:=Vector2(actor.velocity.x,actor.velocity.z).length()
			var back:float=profiles[index].x;var side:float=profiles[index].y
			var expected:float=[4.0,side,4.0,back,1.0/sqrt(.5/(side*side)+.5/(back*back)),0.0,1.0/sqrt(.5/(side*side)+.5/16.0),side,side,0.0][current]
			if t-margins[current]>.1 and margins[current+1]-t>.1:
				seen[index][current]+=1
				correct[index][current]=correct[index][current] and absf(speed-expected)<.002
			if delta>0:
				var movement:=Vector2(actor.position.x-previous[index].x,actor.position.z-previous[index].z).length()
				bounded=bounded and movement<=4*delta+.002
				var yaw:float=actor.get_node("Visual").rotation.y
				facing=facing and absf(angle_difference(yaws[index],yaw))<=3.5*delta+.002
				yaws[index]=yaw
			previous[index]=actor.position
			var skeleton:Skeleton3D=experiment.skins[index].skeleton
			rig_ok=rig_ok and skeleton.get_bone_count()==19
			for bone in range(19):rig_ok=rig_ok and skeleton.get_bone_global_pose(bone).origin.is_finite()
		prior_time=t
	for index in range(3):
		for current in range(10):expect(seen[index][current]>3 and correct[index][current],"profile %d: %s actual speed and normalized diagonal cap"%[index,experiment.STAGES[current]])
	expect(bounded,"actual translation stays within 4 m/s; no diagonal boost or teleport")
	expect(facing,"Option B body yaw remains bounded while camera-relative input turns")
	expect(rig_ok,"all shared worker rigs retain nineteen finite bones")
	expect(experiment.finished and used>800 and used<1100,"all transition stages executed within finite budgets")
	experiment.queue_free();await process_frame
	print("Moving walk experiment: %d checks, %d failures; complete=true; visual_acceptance=false"%[checks,failures])
	quit(0 if failures==0 else 1)
