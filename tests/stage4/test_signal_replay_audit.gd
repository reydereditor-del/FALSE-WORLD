extends SceneTree
## Focused actual-target audit; injected clock/fixture poses isolate call boundaries.
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func expect(value: bool, label: String) -> void:
	checks += 1
	print("PASS: " if value else "FAIL: ", label)
	if not value:
		failures += 1
		push_error(label)
func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame
func run() -> void:
	var world := load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D
	root.add_child(world)
	var loop := world.get_node("ObjectiveLoop")
	loop.set_physics_process(false)
	var area := world.get_node("LocalArea")
	area.set_physics_process(false)
	for controller in area.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	var actor := area.get_node("Character") as CharacterMotor
	actor.get_node("LocalController").set_physics_process(false)
	actor.global_position = Vector3(195.8, 0.1, 118.1)
	await frames(20)
	expect(loop.pickup.begin(actor), "real component reachable")
	loop.pickup.advance(actor, 0.25)
	expect(loop.objective.phase == SignalObjective.Phase.CARRYING, "current build requires one service module, not two final-game parts")
	actor.global_position = Vector3(228.8, 0.1, 125.8)
	await frames(20)
	expect(loop.device.begin(actor), "real device accepts carrier")
	loop.device.advance(actor, 4.0)
	var pending_blocked := true
	for i in range(120):
		pending_blocked = pending_blocked and not loop.device.begin(actor)
		loop.device.advance(actor, 1.0 / 60)
	expect(pending_blocked and loop.objective.calls_sent == 1 and loop.objective.remaining == 5,
		"repeated E cannot replay/reset a pending call")
	loop.objective.advance_time(5, loop.player_in_yard())
	expect(loop.objective.phase == SignalObjective.Phase.READY and loop.objective.successes == 0,
		"waiting at cabinet misses the separate yard; call rearms without success")
	expect(loop.objective.installed and not loop.device.is_complete and loop.device.progress_seconds == 0,
		"empty arrival retains component and intentionally rearms timed work")
	expect(loop.device.begin(actor), "new activation after empty arrival is permitted")
	loop.device.advance(actor, 4)
	expect(loop.objective.calls_sent == 2 and loop.objective.phase == SignalObjective.Phase.WAITING,
		"retry is a second call with its own wait")
	actor.global_position = Vector3(220, 0.1, 140)
	await frames(20)
	loop.objective.advance_time(5, loop.player_in_yard())
	expect(loop.objective.phase == SignalObjective.Phase.SUCCESS and loop.objective.successes == 1,
		"countdown offers actual spatially gated prototype extraction")
	actor.global_position = Vector3(228.8, 0.1, 125.8)
	await frames(20)
	var terminal_blocked := true
	for i in range(120):
		terminal_blocked = terminal_blocked and not loop.device.begin(actor)
		loop.device.advance(actor, 1.0 / 60)
		loop.objective.advance_time(1, false)
	expect(terminal_blocked and loop.objective.calls_sent == 2 and loop.objective.successes == 1,
		"completed success cannot replay, even after banner expires and player returns")
	world.queue_free()
	await frames(4)
	print("Replay audit: %d checks, %d failures; complete=true" % [checks, failures])
	quit(0 if failures == 0 else 1)
