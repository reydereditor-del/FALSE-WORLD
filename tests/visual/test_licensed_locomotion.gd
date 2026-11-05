extends SceneTree
## Explicit installed-asset checks; does not pass silently without the licensed inputs.
var checks:=0
var failures:=0
func _initialize()->void:call_deferred("run")
func expect(ok:bool,label:String)->void:
	checks+=1;print("PASS: " if ok else "FAIL: ",label)
	if not ok:failures+=1;push_error(label)
func frames(count:int)->void:
	for i in range(count):await physics_frame;await process_frame
func run()->void:
	if not LicensedWalks.installed():push_error("Install the user-licensed archives before running this suite");quit(2);return
	var world:=load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D;root.add_child(world)
	var area:=world.get_node("LocalArea")
	var actor:=area.get_node("Character") as CharacterMotor
	var skin:=actor.get_node("Visual/WorkerPresentation") as WorkerPresentation
	await frames(2)
	expect(actor.directional_speeds_enabled and actor.move_speed==4,"installed Option B caps enabled; forward speed remains four")
	expect(skin.licensed_walks_installed and skin.skeleton.get_bone_count()==19,"original nineteen-bone worker receives installed animation library")
	for prefix in ["walk_","run_"]:
		for direction in LicensedWalks.DIRECTIONS:
			var clip:=skin.animation_player.get_animation("Licensed/"+prefix+direction)
			var valid:=clip.get_track_count()==38 and clip.loop_mode==Animation.LOOP_LINEAR
			for track in range(clip.get_track_count()):
				var first:Variant=clip.track_get_key_value(track,0)
				var last:Variant=clip.track_get_key_value(track,clip.track_get_key_count(track)-1)
				valid=valid and (first.angle_to(last)<.001 if first is Quaternion else first.distance_to(last)<.00001)
			expect(valid,prefix+direction+": all nineteen joints bind and loop without root travel")
	actor.get_node("LocalController").set_physics_process(false)
	area.set_physics_process(false)
	for c in area.controllers:c.set_physics_process(false);c.motor.set_move_intent(Vector3.ZERO)
	actor.set_facing_intent(Vector3.FORWARD)
	for direction in [Vector3.FORWARD,Vector3.BACK,Vector3.LEFT,Vector3.RIGHT,Vector3(1,0,-1).normalized(),Vector3(1,0,1).normalized()]:
		actor.global_position=Vector3(220,.1,140);actor.velocity=Vector3.ZERO;actor.get_node("Visual").rotation.y=0
		actor.set_move_intent(direction);await frames(25)
		var expected:=4.0 if direction==Vector3.FORWARD else (2.1009029 if direction.z<0 and direction.x!=0 else 1.6)
		expect(absf(Vector2(actor.velocity.x,actor.velocity.z).length()-expected)<.002,"real physical speed matches directional envelope: "+str(direction))
		expect(not skin.directional_clip_missing and skin.current_state!=&"Idle","actual motion has directional stepping, not idle: "+str(direction))
	actor.set_move_intent(Vector3.ZERO);await frames(25)
	expect(skin.current_state==&"Idle" and skin.animation_player.current_animation==&"Presentation/Idle","stopping restores existing breathing/resting idle")
	for c in area.controllers:
		expect(not c.motor.directional_speeds_enabled and not c.motor.has_facing_intent and c.motor.move_speed==4,"AI controller/movement configuration unchanged")
	world.queue_free();await frames(3)
	print("Licensed locomotion: %d checks, %d failures; complete=true"%[checks,failures])
	quit(0 if failures==0 else 1)
