extends SceneTree
## Built-in Godot runner. Synthetic input is not a manual camera/input playtest.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + label)
	else:
		print("PASS: " + label)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func _run() -> void:
	var packed := load("res://scenes/prototype/m1_graybox.tscn") as PackedScene
	expect(packed != null, "standalone scene loads")
	if packed == null:
		quit(1)
		return
	var world := packed.instantiate()
	root.add_child(world)
	var actor := world.get_node("Character") as CharacterMotor
	var controller := actor.get_node("LocalController")
	var rig := actor.get_node("CameraRig") as FollowCamera
	var target := world.get_node("Lever") as WorkTarget
	var interactor := actor.get_node("Interactor") as CharacterInteractor
	controller.set_physics_process(false)
	controller.set_process_unhandled_input(false)
	await frames(30)
	expect(actor.is_on_floor() and absf(actor.position.y) < 0.05, "gravity settles on ground")
	actor.set_move_intent(Vector3(0, 0, -1))
	await frames(120)
	expect(actor.position.z > 1.3 and actor.position.z < 1.5, "obstacle blocks forward travel")
	expect(actor.get_slide_collision_count() > 0, "obstacle produces physical collision")
	actor.set_move_intent(Vector3.ZERO)
	actor.position = Vector3(5, 0.05, 5)
	await frames(5)
	var origin := actor.position
	actor.set_move_intent(Vector3(10, 7, -10))
	await frames(30)
	var displacement := actor.position - origin
	expect(displacement.x > 0.5 and displacement.z < -0.5, "world-space motor command moves diagonally")
	expect(Vector2(actor.velocity.x, actor.velocity.z).length() <= actor.move_speed + 0.001,
		"diagonal command cannot exceed speed limit")
	expect(actor.is_on_floor(), "walking retains ground contact")
	actor.set_move_intent(Vector3.ZERO)
	await frames(2)
	expect(Vector2(actor.velocity.x, actor.velocity.z).is_zero_approx(), "release stops horizontal movement")

	rig.orbit(Vector2(100, -100000))
	expect(is_equal_approx(rig.pitch_pivot.rotation.x, deg_to_rad(rig.maximum_pitch_degrees)),
		"orbit pitch upper limit")
	rig.orbit(Vector2(0, 100000))
	expect(is_equal_approx(rig.pitch_pivot.rotation.x, deg_to_rad(rig.minimum_pitch_degrees)),
		"orbit pitch lower limit")
	rig.rotation.y = PI / 2.0
	var direction := rig.movement_direction(Vector2(0, -1))
	expect(direction.is_equal_approx(Vector3.LEFT), "W direction follows camera yaw, not pitch")
	rig.rotation.y = 0.0
	rig.pitch_pivot.rotation.x = 0.0
	actor.position = Vector3(5, 0, 10)
	await frames(5)
	expect(rig.spring.get_hit_length() < rig.spring.spring_length - 0.5,
		"spring arm retracts against yard wall")

	# Real adapter, with synthetic actions rather than OS keyboard events.
	actor.position = Vector3(5, 0, 5)
	controller.set_physics_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var forward := InputEventKey.new()
	forward.physical_keycode = KEY_W
	forward.pressed = true
	Input.parse_input_event(forward)
	Input.flush_buffered_events()
	await frames(12)
	forward.pressed = false
	Input.parse_input_event(forward)
	Input.flush_buffered_events()
	expect(actor.position.z < 4.5, "local input adapter passes forward intent to motor")
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	controller._unhandled_input(escape)
	await frames(3)
	expect(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and actor.velocity.is_zero_approx(),
		"Escape releases mouse and stops controls")
	controller.set_physics_process(false)

	actor.position = Vector3(-3, 0, 1.5)
	await frames(3)
	var counts := [0, 0, 0]
	target.started.connect(func(): counts[0] += 1)
	target.canceled.connect(func(): counts[1] += 1)
	target.completed.connect(func(): counts[2] += 1)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	controller._unhandled_input(click)
	Input.action_press("interact")
	controller._physics_process(1.0)
	Input.action_release("interact")
	expect(counts[0] == 1 and is_equal_approx(target.progress_seconds, 1.0), "E intent starts work and advances")
	var partial_angle := target.lever_pivot.rotation.z
	expect(partial_angle > -PI / 4.0 and partial_angle < PI / 4.0, "partial work physically rotates lever")
	controller._physics_process(1.0)
	expect(counts[1] == 1 and is_equal_approx(target.progress_seconds, 1.0), "release cancels and saves partial progress")
	await frames(3)
	expect(is_equal_approx(target.progress_seconds, 1.0), "canceled work does not advance with time")
	interactor.step(true, 0.2)
	expect(counts[0] == 2 and is_equal_approx(target.progress_seconds, 1.2), "resume continues saved progress")
	controller._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	expect(counts[1] == 2 and is_equal_approx(target.progress_seconds, 1.2),
		"focus loss cancels active interaction without loss")
	controller._unhandled_input(click)
	interactor.step(true, 0.0)
	target.advance(actor, -1.0)
	expect(is_equal_approx(target.progress_seconds, 1.2), "negative elapsed time cannot rewind work")

	# A second inert Node3D is a test worker, not an AI implementation.
	var other := Node3D.new()
	world.add_child(other)
	other.position = Vector3(-4, 0, 1)
	expect(not target.begin(other), "another worker cannot share an active action")
	target.advance(other, 1.0)
	target.cancel(other)
	expect(is_equal_approx(target.progress_seconds, 1.2), "non-owner cannot advance or cancel work")
	actor.position = Vector3(5, 0, 5)
	interactor.step(true, 1.0)
	expect(counts[1] == 3 and is_equal_approx(target.progress_seconds, 1.2), "leaving range cancels without loss")
	expect(not target.begin(actor), "out-of-range start rejected")

	# A real temporary collision body isolates line-of-sight validation from distance.
	var blocker := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 2, 0.2)
	shape.shape = box
	blocker.add_child(shape)
	world.add_child(blocker)
	blocker.position = Vector3(-3, 1, 0.8)
	actor.position = Vector3(-3, 0, 1.5)
	await frames(3)
	expect(not target.begin(actor), "wall blocks in-range interaction")
	blocker.queue_free()
	await frames(3)
	expect(target.begin(other), "new worker can resume after cancellation")
	target.advance(other, 0.3)
	other.free()
	interactor.step(true, 0.2)
	expect(is_equal_approx(target.progress_seconds, 1.7), "freed worker does not leave target locked")
	interactor.step(true, 10.0)
	expect(target.is_complete and is_equal_approx(target.progress_seconds, target.duration_seconds),
		"completion clamps to configurable duration")
	expect(is_equal_approx(target.lever_pivot.rotation.z, PI / 4.0), "completed lever stays in set position")
	interactor.step(false, 1.0)
	interactor.step(true, 10.0)
	expect(counts[2] == 1 and not target.begin(actor), "completion emits once and cannot restart")
	world.queue_free()
	await frames(2)
	print("M1: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
