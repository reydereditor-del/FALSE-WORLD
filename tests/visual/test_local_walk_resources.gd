extends SceneTree
## Offline authored-resource invariants on the actual unchanged worker skin.
var checks := 0
var failures := 0
func _initialize() -> void:call_deferred("run")
func expect(ok: bool, text: String) -> void:
	checks+=1
	print("PASS: " if ok else "FAIL: ",text)
	if not ok:failures+=1;push_error(text)
func run() -> void:
	var model := load("res://assets/visual/models/worker.glb").instantiate() as Node3D
	model.scale=Vector3.ONE*1.2;model.rotation.y=PI;root.add_child(model)
	var player := model.find_child("AnimationPlayer",true,false) as AnimationPlayer
	var skeleton := model.find_child("Skeleton3D",true,false) as Skeleton3D
	var library := AnimationLibrary.new()
	var clips := ["BackwardWalk","StrafeLeft","StrafeRight"]
	var directions := [Vector3.BACK,Vector3.LEFT,Vector3.RIGHT]
	for name in clips:library.add_animation(name,load("res://assets/visual/animations/"+name.to_snake_case()+".tres"))
	player.add_animation_library("Local",library)
	expect(skeleton.get_bone_count()==19,"original nineteen-bone skeleton retained")
	for index in range(3):
		var animation := library.get_animation(clips[index])
		var loop_ok := animation.loop_mode==Animation.LOOP_LINEAR
		for track in range(animation.get_track_count()):
			var first: Variant=animation.track_get_key_value(track,0)
			var last: Variant=animation.track_get_key_value(track,animation.track_get_key_count(track)-1)
			if first is Quaternion:loop_ok=loop_ok and first.angle_to(last)<.001
			else:loop_ok=loop_ok and first.distance_to(last)<.00001
		expect(loop_ok,clips[index]+": exact matching loop endpoints on all tracks")
		player.play("Local/"+clips[index],0);player.advance(0);player.pause()
		var slip:=0.0
		var lift:=0.0
		var min_gap:=INF
		var root_low:=Vector3(INF,INF,INF)
		var root_high:=Vector3(-INF,-INF,-INF)
		var knee_ok:=true
		var finite:=true
		var previous:Array[Vector3]=[]
		for step in range(181):
			var phase:=float(step)/180.0
			player.seek(phase*animation.length,true)
			var positions:Array[Vector3]=[]
			for bone in range(19):
				var point:=skeleton.global_transform*skeleton.get_bone_global_pose(bone).origin
				positions.append(point)
				finite=finite and point.is_finite()
			root_low=root_low.min(positions[0]);root_high=root_high.max(positions[0])
			min_gap=minf(min_gap,positions[17].x-positions[13].x)
			for side in range(2):
				var ankle:=13 if side==0 else 17
				var q:=fposmod(phase+(0.0 if side==0 else .5)+(.5 if index==2 else 0.0),1.0)
				if step>0 and q>.015 and q<.59:
					var expected:Vector3=-directions[index]*float(animation.get_meta("distance_per_cycle"))/180.0
					slip=maxf(slip,(positions[ankle]-previous[ankle]-expected).length())
				lift=maxf(lift,positions[ankle].y-.103)
				knee_ok=knee_ok and positions[ankle-1].y>positions[ankle].y and positions[ankle-2].y>positions[ankle-1].y
			previous=positions
		print(clips[index]," max planted displacement error/tick=",slip," lift=",lift," ankle gap=",min_gap," pelvis range=",root_high-root_low)
		expect(finite and knee_ok,clips[index]+": finite actual bone poses; knees between hips and ankles")
		expect(slip<.002,clips[index]+": stance feet follow treadmill within 2 mm per sampled tick")
		expect(lift>.055 and lift<.08 and min_gap>.08,clips[index]+": real swing clearance and separated feet")
		expect(root_high.z-root_low.z<.0001 and root_high.x-root_low.x<.025 and root_high.y-root_low.y<.017,
			clips[index]+": bounded pelvis sway/bob without horizontal root travel")
	model.queue_free()
	await process_frame
	print("Local walk resources: %d checks, %d failures; complete=true"%[checks,failures])
	quit(0 if failures==0 else 1)
