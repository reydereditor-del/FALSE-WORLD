extends SceneTree
## Real inherited visual scene + existing body/interactor/controller/AI. Finite test-only poses.

var checks := 0
var failures := 0
var frames_used := 0
var started := 0
var world: Node3D
var loop: Node3D
var area: Node3D
var actor: CharacterMotor
var interactor: CharacterInteractor


func _initialize() -> void:
	started = Time.get_ticks_msec()
	call_deferred("run")


func expect(value: bool, label: String) -> void:
	checks += 1
	if value:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)


func frames(count: int) -> void:
	for i in range(count):
		frames_used += 1
		if frames_used > 8500 or Time.get_ticks_msec() - started > 120000:
			push_error("Stage4 incomplete: finite frame/wall budget exhausted")
			quit(2)
			return
		await physics_frame
		await process_frame


func place(point: Vector3) -> void:
	interactor.step(false, 0)
	actor.global_position = point + Vector3.UP * 0.1
	actor.velocity = Vector3.ZERO
	actor.set_move_intent(Vector3.ZERO)
	await frames(20)


func hold(count: int) -> void:
	for i in range(count):
		interactor.step(true, 1.0 / 60)
		await frames(1)


func walk(points: PackedVector3Array) -> bool:
	var all_reached := true
	var supported := true
	var max_air := 0
	for point in points:
		var reached := false
		for tick in range(650):
			var direction := point - actor.global_position
			direction.y = 0
			if direction.length() < 0.22:
				reached = true
				break
			interactor.step(false, 0)
			var previous := actor.global_position
			actor.set_move_intent(direction.normalized())
			await frames(1)
			supported = supported and actor.global_position.distance_to(previous) < 0.08
			max_air = 0 if actor.is_on_floor() else max_air + 1
			supported = supported and max_air <= 4
		all_reached = all_reached and reached
		if not reached:
			print("Walk blocked at ", actor.global_position, " toward ", point)
			break
	actor.set_move_intent(Vector3.ZERO)
	await frames(2)
	return all_reached and supported


func connect_world(next: Node3D) -> void:
	world = next
	loop = world.get_node("ObjectiveLoop")
	area = world.get_node("LocalArea")
	actor = area.get_node("Character")
	interactor = actor.get_node("Interactor")
	actor.get_node("LocalController").set_physics_process(false)


func run() -> void:
	var next := load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D
	root.add_child(next)
	current_scene = next
	connect_world(next)
	await frames(20)
	expect(loop.objective.phase == SignalObjective.Phase.SEARCH and area.actors.size() == 4, "real Stage4 visual composition starts with one module and one human/three AI")
	expect(world.get_node("StationArt").presentations.size() == 4 and actor.move_speed == 4.0, "shared visual benchmark and production movement retained")
	expect(loop.pickup.objective == loop.objective and loop.device.objective == loop.objective, "explicit single objective instance wired to actual WorkTarget adapters")
	var map: RID = area.controllers[0].navigator.get_navigation_map()
	var reachable := NavigationServer3D.map_get_iteration_id(map) > 0
	for site in area.sites:
		var nearest := NavigationServer3D.map_get_closest_point(map, site.position)
		var path := NavigationServer3D.map_get_path(map, Vector3(220, 0, 140), nearest, true)
		reachable = reachable and nearest.distance_to(site.position) < 0.75 and not path.is_empty()
		if not path.is_empty():
			reachable = reachable and path[-1].distance_to(nearest) < 0.5
	expect(reachable, "all ten old AI sites remain reachable on Stage4-only navigation bake")
	var starts: Array[Vector3] = []
	for controller in area.controllers:
		starts.append(controller.motor.global_position)
	await frames(900)
	var moved := 0
	for i in range(3):
		if area.controllers[i].motor.global_position.distance_to(starts[i]) > 1:
			moved += 1
	expect(moved == 3 and area.max_sensors_per_tick == 1, "all real AI continue ordinary movement/perception scheduling during objective search")
	# Controlled objective-area sighting, using only the unchanged actual LOS adapter.
	area.set_physics_process(false)
	for controller in area.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
	await place(Vector3(228.8, 0, 125.8))
	var driver: ObservationController = area.controllers[0]
	driver.motor.global_position = Vector3(228.8, 0.1, 132)
	driver.motor.velocity = Vector3.ZERO
	driver.motor.get_node("Visual").rotation.y = 0
	await frames(20)
	driver.initialize()
	area.sensors[0].sample(4000)
	driver.plan(4000)
	var fact: Dictionary = driver.memory.snapshot(4000).get(&"F11", {})
	expect(not fact.is_empty() and fact.source == &"vision" and driver.decisions.state == ObservationDecisions.State.OBSERVE,
		"actual sight of player at signal cabinet triggers normal vision-backed Observe")
	var old_point: Vector3 = fact.get("position", Vector3.ZERO)
	await place(Vector3(200, 0, 133))
	var investigated := false
	for tick in range(4015, 4211, 15):
		area.sensors[0].sample(tick)
		driver.plan(tick)
		if driver.decisions.state == ObservationDecisions.State.INVESTIGATE:
			investigated = true
			break
	expect(investigated and driver.decisions.evidence.get("position", Vector3.ZERO).distance_to(old_point) < 0.01,
		"lost sight near objective uses frozen old evidence, not live objective/player tracking")
	for i in range(3):
		area.controllers[i].motor.global_position = Vector3(180 + i * 3, 0.1, 180)
		area.controllers[i].motor.velocity = Vector3.ZERO
	# Independent rejection fixture: at device before collecting anything.
	await place(Vector3(228.8, 0, 125.8))
	await hold(60)
	expect(interactor.target == loop.device and loop.device.progress_seconds == 0 and not loop.objective.installed, "device rejects holding E without module")
	await place(Vector3(220, 0, 140))
	await frames(30)
	expect(loop.objective.successes == 0, "standing in extraction yard without a sent call does not win")
	# Full playable path: after setup at entry, no poses/teleports until completion.
	await place(Vector3(200, 0, 133))
	expect(await walk(PackedVector3Array([Vector3(200, 0, 118), Vector3(195.8, 0, 118.1)])), "walk from visual entry into building to real module")
	expect(interactor.target == loop.pickup, "nearby unblocked component is selected by existing interactor")
	await hold(6)
	interactor.step(false, 0)
	expect(loop.objective.phase == SignalObjective.Phase.SEARCH and not loop.pickup.is_complete, "interrupted short pickup does not lose or duplicate world component")
	await hold(14)
	expect(loop.objective.phase == SignalObjective.Phase.CARRYING and loop.objective.carrier_id == actor.get_instance_id(), "actual E pickup assigns the single module to the actor")
	expect(not loop.pickup.visible and loop.pickup.collision_layer == 0 and not loop.objective.installed, "collected world object is removed from view/collision while carried")
	expect(await walk(PackedVector3Array([Vector3(200, 0, 118), Vector3(200, 0, 129), Vector3(210, 0, 129), Vector3(228.8, 0, 125.8)])), "carry component by normal walking through door to cabinet")
	expect(interactor.target == loop.device and loop.device.can_reach(actor), "real device is within physical range and clear LOS")
	var barrier := StaticBody3D.new()
	barrier.position = Vector3(229.4, 1.25, 125.2)
	var barrier_collision := CollisionShape3D.new()
	var barrier_shape := BoxShape3D.new()
	barrier_shape.size = Vector3(1.2, 2.5, 0.12)
	barrier_collision.shape = barrier_shape
	barrier.add_child(barrier_collision)
	world.add_child(barrier)
	await frames(3)
	await hold(10)
	expect(not loop.device.can_reach(actor) and loop.device.progress_seconds == 0, "actual obstruction blocks device activation through solid geometry")
	barrier.queue_free()
	await frames(4)
	await hold(60)
	interactor.step(false, 0)
	var partial: float = loop.device.progress_seconds
	expect(partial > 0.9 and partial < 1.1 and not loop.objective.installed and loop.objective.phase == SignalObjective.Phase.CARRYING,
		"timed activation remains incomplete after one second and retains carried component")
	await frames(20)
	expect(is_equal_approx(loop.device.progress_seconds, partial), "release immediately stops work and retains progress")
	await hold(15)
	actor.get_node("LocalController")._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	var focus_partial: float = loop.device.progress_seconds
	await frames(5)
	expect(loop.device._worker == null and is_equal_approx(loop.device.progress_seconds, focus_partial), "focus loss cancels active work without losing progress")
	# Walk away while E remains requested; target selection must cancel on lost reach.
	actor.set_move_intent(Vector3.BACK)
	await hold(90)
	actor.set_move_intent(Vector3.ZERO)
	var away_progress: float = loop.device.progress_seconds
	await hold(30)
	expect(loop.device._worker == null and is_equal_approx(loop.device.progress_seconds, away_progress) and not loop.objective.installed,
		"walking out of range while E held cancels work without remote activation")
	expect(await walk(PackedVector3Array([Vector3(228.8, 0, 125.8)])), "normal walking returns to interrupted device")
	for i in range(260):
		await hold(1)
		if loop.objective.phase == SignalObjective.Phase.WAITING:
			break
	expect(loop.objective.phase == SignalObjective.Phase.WAITING and loop.objective.installed and loop.objective.carrier_id == 0,
		"resumed complete hold installs exactly once and sends actual call")
	expect(loop.objective.calls_sent == 1 and loop.objective.successes == 0 and loop.get_node("InstalledModule").visible, "sending displays installed module but is not immediate success")
	await hold(5)
	expect(loop.objective.calls_sent == 1 and loop.objective.remaining < 5, "continued held E cannot duplicate/reset pending call")
	# Follow the clear side of the existing station sign rather than through its board.
	expect(await walk(PackedVector3Array([Vector3(220, 0, 132), Vector3(220, 0, 140)])), "leave cabinet and walk around existing sign to real yard before arrival")
	area.controllers[1].motor.global_position = Vector3(221, 0.1, 140)
	await frames(80)
	expect(loop.objective.phase == SignalObjective.Phase.SUCCESS and loop.objective.successes == 1, "wait completes with player in yard even with nearby AI present")
	loop._refresh_feedback()
	expect(loop.feedback.text.contains("PROTOTYPE EXTRACTION COMPLETE") and not loop.feedback.text.contains("K72"), "minimal local success feedback contains no hidden actor/role roster")
	await frames(370)
	loop._refresh_feedback()
	expect(loop.objective.successes == 1 and loop.objective.banner_remaining == 0 and loop.feedback.text.contains("run complete"), "temporary success banner ends without extra awards or full-game claims")
	# Real R reload path, not a manually reset state object.
	var key := InputEventKey.new()
	key.physical_keycode = KEY_R
	key.pressed = true
	loop._unhandled_key_input(key)
	await frames(8)
	connect_world(current_scene as Node3D)
	expect(loop.objective.phase == SignalObjective.Phase.SEARCH and loop.objective.calls_sent == 0 and loop.pickup.visible and loop.pickup.collision_layer == 1,
		"R reload creates one fresh module and clean objective state")
	expect(area.actors.size() == 4 and world.get_node("StationArt").presentations.size() == 4, "reset does not accumulate actors or presentation rigs")
	# Separate miss/retry fixture: normal pickup/hold interfaces, poses only between cases.
	area.set_physics_process(false)
	for controller in area.controllers:
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
		controller.motor.global_position = Vector3(180, 0.1, 170)
	await place(Vector3(195.8, 0, 118.1))
	await hold(20)
	await place(Vector3(228.8, 0, 125.8))
	await hold(245)
	expect(loop.objective.phase == SignalObjective.Phase.WAITING, "second fixture sends a real timed call")
	interactor.step(false, 0)
	await frames(310)
	expect(loop.objective.phase == SignalObjective.Phase.READY and loop.objective.successes == 0 and loop.objective.installed and not loop.device.is_complete,
		"empty arrival keeps installed part and rearms actual work target")
	await hold(245)
	expect(loop.objective.calls_sent == 2 and loop.objective.phase == SignalObjective.Phase.WAITING, "new four-second call reuses installed module without another pickup")
	await place(Vector3(220, 0, 140))
	await frames(310)
	expect(loop.objective.phase == SignalObjective.Phase.SUCCESS and loop.objective.successes == 1, "repeat call can finish the local loop")
	expect(not area.get_node("AIDebugOverlay").enabled, "existing developer diagnostics remain gated/off")
	current_scene = null
	world.queue_free()
	await frames(4)
	print("Signal integration: %d checks, %d failures; complete=true" % [checks, failures])
	quit(0 if failures == 0 else 1)
