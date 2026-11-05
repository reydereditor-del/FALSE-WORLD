extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func expect(ok: bool, label: String) -> void:
	checks += 1
	print("PASS: " if ok else "FAIL: ",label)
	if not ok:
		failures += 1
		push_error(label)
func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func release() -> void:
	for action in ["move_forward","move_back","move_left","move_right"]: Input.action_release(action)
func run() -> void:
	var world := load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D
	root.add_child(world)
	world.get_node("ObjectiveLoop").set_physics_process(false)
	var area := world.get_node("LocalArea")
	area.set_physics_process(false)
	for c in area.controllers:
		c.set_physics_process(false)
		c.motor.set_move_intent(Vector3.ZERO)
		c.motor.global_position = Vector3(180,0.1,180)
	var actor := area.get_node("Character") as CharacterMotor
	var rig := actor.get_node("CameraRig") as FollowCamera
	var skin := actor.get_node("Visual/WorkerPresentation") as WorkerPresentation
	var actions := [["move_forward"],["move_back"],["move_left"],["move_right"],
		["move_forward","move_left"],["move_forward","move_right"],["move_back","move_left"],["move_back","move_right"]]
	var vectors := [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0),Vector2(-1,-1),Vector2(1,-1),Vector2(-1,1),Vector2(1,1)]
	for yaw in [0.0, PI/2]:
		for i in range(actions.size()):
			release()
			actor.global_position = Vector3(220,.1,140)
			actor.velocity = Vector3.ZERO
			rig.rotation.y = yaw
			actor.get_node("Visual").rotation.y = yaw
			await frames(3)
			for action in actions[i]: Input.action_press(action)
			await frames(16)
			var speeds := [4.0,1.6,1.6,1.6,2.1009029,2.1009029,1.6,1.6]
			var scalar: float = speeds[i] if actor.directional_speeds_enabled else 4.0
			var expected := rig.movement_direction(vectors[i].normalized()) * scalar
			expect(Vector2(actor.velocity.x-expected.x,actor.velocity.z-expected.z).length() < .01 and
				absf(angle_difference(actor.get_node("Visual").rotation.y,yaw)) < .001,
				"real input camera yaw %.2f case %d: normalized translation with camera-facing body" % [yaw,i])
			if i > 0:
				if actor.directional_speeds_enabled:
					var names := ["run_forward","walk_backward","walk_left","walk_right","walk_forward_left","walk_forward_right","walk_backward_left","walk_backward_right"]
					expect(not skin.directional_clip_missing and skin.animation_player.current_animation == "Licensed/"+names[i], "installed directional clip matches actual local velocity")
				else:
					expect(skin.directional_clip_missing and skin.current_state == &"Idle", "uninstalled baseline retains its documented neutral fallback")
	release()
	await frames(20)
	var stopped := actor.global_position
	await frames(20)
	expect(actor.global_position.distance_to(stopped) < .005 and skin.current_state == &"Idle", "released input is stationary with corrected resting pose")
	rig.rotation.y = 0
	actor.get_node("Visual").rotation.y = 0
	Input.action_press("move_forward")
	await frames(20)
	expect(skin.current_state == &"Walk" and not skin.directional_clip_missing, "existing verified forward clip plays for actual forward locomotion")
	rig.rotation.y = PI/2
	var smooth := true
	for i in range(40):
		var previous: float = actor.get_node("Visual").rotation.y
		await frames(1)
		smooth = smooth and absf(angle_difference(previous,actor.get_node("Visual").rotation.y)) < 3.5/60+.002
	expect(smooth and absf(angle_difference(actor.get_node("Visual").rotation.y,PI/2)) < .001,"body smoothly tracks changed camera yaw during locomotion")
	rig.pitch_pivot.rotation.x = deg_to_rad(-80)
	await frames(3)
	expect(absf(actor.get_node("Visual").rotation.x) < .001 and absf(actor.get_node("Visual").rotation.z) < .001 and absf(actor.velocity.y) < .1,
		"camera pitch does not tilt body or add vertical movement")
	release()
	var steps_ok := true
	for i in range(32):
		release()
		Input.action_press(actions[i%4][0])
		var previous := actor.global_position
		await frames(1)
		steps_ok = steps_ok and actor.global_position.distance_to(previous) < .08
	expect(steps_ok,"rapid WASD switches do not teleport or increase speed")
	release()
	var bot: CharacterMotor = area.controllers[0].motor
	bot.set_move_intent(Vector3.RIGHT)
	await frames(40)
	var bot_yaw: float = bot.get_node("Visual").rotation.y
	rig.rotation.y = -PI/2
	await frames(10)
	expect(not bot.has_facing_intent and absf(angle_difference(bot.get_node("Visual").rotation.y,bot_yaw)) < .001,
		"AI keeps movement-facing orientation independent of human camera")
	world.queue_free()
	await frames(4)
	print("Option B: %d checks, %d failures; complete=true" % [checks,failures])
	quit(0 if failures == 0 else 1)
