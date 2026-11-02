extends SceneTree

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	call_deferred("run")


func expect(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func fact(tick: int, position: Vector3) -> Dictionary:
	return {"observer": &"K72", "subject": &"F11", "event": &"seen", "position": position,
		"tick": tick, "confidence": 1.0, "source": &"vision"}


func run() -> void:
	expect(AIDebugOverlay.developer_build(true, true), "editor debug binary permits deliberate diagnostics")
	expect(not AIDebugOverlay.developer_build(false, true)
		and not AIDebugOverlay.developer_build(true, false)
		and not AIDebugOverlay.developer_build(false, false),
		"all non-editor or non-debug feature combinations reject diagnostics")
	var memory := LocalMemory.new()
	var stored := fact(100, Vector3(3, 0, 1))
	memory.remember(stored, 100)
	var copy := memory.inspect(399)
	copy[&"F11"].position = Vector3(99, 0, 99)
	expect(memory.inspect(399)[&"F11"].position == stored.position,
		"diagnostic view is a deep copy of existing legitimate memory")
	expect(memory.inspect(400).is_empty() and memory.contains_observation(stored),
		"inspection hides exact-boundary expiry without mutating stored memory")
	expect(memory.inspect(99).is_empty() and memory.contains_observation(stored),
		"inspection hides future facts without expiring or rewriting them")

	var world = load("res://scenes/prototype/stage3b1_observation.tscn").instantiate()
	root.add_child(world)
	var human := world.get_node("Character") as CharacterMotor
	var local_control := human.get_node("LocalController")
	local_control.set_physics_process(false)
	local_control.set_process_unhandled_input(false)
	world.set_physics_process(false)
	for index in range(3):
		var controller := world.controllers[index] as ObservationController
		controller.set_physics_process(false)
		controller.motor.set_move_intent(Vector3.ZERO)
		controller.memory = LocalMemory.new()
		world.sensors[index].memory = controller.memory
		controller.initialize()
		for connection in world.sensors[index].observed.get_connections():
			world.sensors[index].observed.disconnect(connection.callable)
	world.channel = ObservedFactChannel.new()
	for index in range(3):
		world.channel.register(world.sensors[index], world.sensors[(index + 1) % 3].observer_id,
			world.sensors[index].memory)
	var overlay := world.get_node("AIDebugOverlay") as AIDebugOverlay
	expect(not overlay.enabled and overlay.get_child_count() == 0,
		"overlay defaults off with no UI or timer nodes")
	await frames(12)
	expect(overlay.refresh_count == 0 and not overlay.is_processing() and not overlay.is_physics_processing(),
		"disabled overlay performs no frame polling or snapshot refreshes")
	var f3 := InputEventKey.new()
	f3.physical_keycode = KEY_F3
	f3.pressed = true
	Input.parse_input_event(f3)
	await frames(2)
	expect(overlay.enabled and overlay.get_child_count() == 2 and is_instance_valid(overlay._label),
		"actual F3 input creates the developer panel and active timer")
	expect(overlay._label.text.contains("K72") and overlay._label.text.contains("B14")
		and overlay._label.text.contains("D09"), "panel displays all three internal agent IDs")
	var previous := overlay.refresh_count
	var echo := f3.duplicate() as InputEventKey
	echo.echo = true
	Input.parse_input_event(echo)
	await frames(12)
	expect(overlay.enabled and overlay.refresh_count > previous, "key echo is ignored while enabled refresh timer runs")
	# Actual Escape/click must pass through the visible panel to the existing adapter.
	local_control.set_process_unhandled_input(true)
	var escape := InputEventKey.new()
	escape.physical_keycode = KEY_ESCAPE
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await frames(2)
	expect(not local_control._controls_active and overlay.enabled,
		"Escape still releases existing controls while the panel is visible")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(20, 20)
	Input.parse_input_event(click)
	await frames(2)
	expect(local_control._controls_active and overlay.enabled,
		"click over the visible panel still restores existing controls")
	local_control.set_process_unhandled_input(false)
	var mouse_mode := Input.mouse_mode
	var controls_active: bool = local_control._controls_active
	Input.parse_input_event(f3)
	await frames(2)
	expect(not overlay.enabled and overlay.get_child_count() == 0 and overlay._label == null,
		"second F3 removes rendering, text and timer nodes")
	expect(Input.mouse_mode == mouse_mode and local_control._controls_active == controls_active
		and not world.get_tree().paused, "toggle does not capture mouse, alter control mode or pause gameplay")
	previous = overlay.refresh_count
	await frames(12)
	expect(overlay.refresh_count == previous, "disabled timer no longer reads any debug state")

	var driver := world.controllers[0] as ObservationController
	var receiver := world.controllers[1] as ObservationController
	var actor := driver.motor
	var sensor: LocalPerception = world.sensors[0]
	actor.position = Vector3(0, 0.1, 5)
	actor.get_node("Visual").rotation.y = 0.0
	human.position = Vector3(3, 0.1, 1)
	receiver.motor.position = Vector3(7, 0.1, 5)
	world.controllers[2].motor.position = Vector3(-30, 0.1, 30)
	sensor.candidates = {&"F11": human}
	await frames(3)
	sensor.sample(1000)
	driver.plan(1000)
	var view := AIDebugState.read(driver, 1000)
	var old_point: Vector3 = view.direct_position
	expect(view.state == "Observe" and view.selected_source == "Direct vision"
		and view.direct_at_latest_sample and view.direct_age_ticks == 0,
		"real direct observation displays current sample, state, source and age")
	expect(view.navigation == "Waiting" and view.direct_subject == "F11",
		"observation pause and actually observed subject are represented accurately")
	var stored_before := driver.memory.inspect(1000)
	var next_plan := driver._next_plan_tick
	var decisions_before := driver.decisions.evaluations
	var queries_before := driver.path_queries
	for index in range(10):
		AIDebugState.read(driver, 1000)
	expect(driver.memory.inspect(1000) == stored_before and driver._next_plan_tick == next_plan
		and driver.decisions.evaluations == decisions_before and driver.path_queries == queries_before,
		"repeated diagnostics neither mutate memory/decisions nor trigger navigation queries")

	# Central solid wall occludes an in-range, in-cone human: perception cannot update.
	human.position = Vector3(0, 0.1, -2)
	await frames(3)
	sensor.sample(1015)
	driver.plan(1015)
	view = AIDebugState.read(driver, 1015)
	expect(not view.direct_at_latest_sample and view.direct_age_ticks == 15
		and view.direct_position == old_point, "solid LOS loss is labeled last-seen, with stable old point and increasing age")
	var formatted := AIDebugState.describe(view, 60)
	expect(formatted.contains("last-seen memory") and formatted.contains("0.25s")
		and formatted.contains("Direct vision"), "formatted diagnostics distinguish historical vision from current sight")
	view.direct_position = Vector3(99, 0, 99)
	expect(AIDebugState.read(driver, 1015).direct_position == old_point,
		"modifying returned diagnostics cannot redirect stored knowledge")
	receiver.plan(1015)
	world.channel.advance(1029)
	receiver.plan(1030)
	expect(AIDebugState.read(receiver, 1030).selected_source == "None",
		"report evidence unavailable before the actual delayed delivery")
	world.channel.advance(1030)
	receiver.plan(1045)
	var report_view := AIDebugState.read(receiver, 1045)
	expect(report_view.state == "Observe" and report_view.selected_source == "Delayed team report"
		and report_view.selected_age_ticks == 45 and report_view.direct_position == null
		and report_view.selected_position == old_point,
		"delivered report preserves source and original age without inventing direct vision")
	expect(AIDebugState.read(world.controllers[2], 1045).selected_source == "None",
		"unaddressed agent debug view contains no globally shared report")
	driver.plan(1090)
	view = AIDebugState.read(driver, 1090)
	var frozen_destination: Vector3 = view.destination
	expect(view.state == "Investigate" and view.navigation == "Moving"
		and frozen_destination.distance_to(old_point) < 0.2,
		"investigation displays the actual frozen navigation destination")
	var newer := fact(1100, Vector3(8, 0, 1))
	newer.source = &"team_report"
	newer.observer = &"B14"
	driver.memory.remember(newer, 1100)
	driver.plan(1105)
	view = AIDebugState.read(driver, 1105)
	expect(view.destination == frozen_destination and view.selected_position == old_point
		and view.selected_source == "Direct vision" and view.direct_position == old_point,
		"newer report cannot move selected evidence, nav goal or retained legitimate direct snapshot")
	driver.plan(1300)
	view = AIDebugState.read(driver, 1300)
	expect(view.state == "Resume" and view.navigation == "Waiting" and view.selected_expired
		and view.direct_position == null and view.selected_position == null,
		"evidence expiry clears usable diagnostic points while showing resume/expired status")
	expect(AIDebugState.describe(view, 60).contains("expired"), "expired selected evidence is clearly labeled")
	driver.plan(1360)
	view = AIDebugState.read(driver, 1360)
	expect(view.state == "Explore" and view.selected_source == "None", "return to exploration clears selected evidence display")
	var fields := view.keys()
	expect(not fields.has("is_ai") and not fields.has("role") and not fields.has("hp")
		and not fields.has("human_position") and not fields.has("inventory"),
		"adapter emits no hidden role, inventory, health or world-truth fields")

	# Physical blockage of a valid old-location path: read existing stall/retry flags.
	var barrier := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(6, 3, 0.5)
	shape.shape = box
	barrier.add_child(shape)
	world.add_child(barrier)
	barrier.position = Vector3(0, 1.5, 8)
	actor.position = Vector3(0, 0.1, 5)
	human.position = Vector3(40, 0.1, 40)
	await frames(3)
	driver.initialize()
	driver.stall_timeout_ticks = 30
	driver.decisions.freshness_ticks = 1200
	driver.decisions.investigation_timeout_ticks = 600
	driver.memory = LocalMemory.new()
	driver.memory.freshness_ticks = 1200
	driver.memory.remember(fact(2000, Vector3(0, 0, 12)), 2000)
	driver.plan(2000)
	driver.plan(2090)
	driver.set_physics_process(true)
	var statuses: Dictionary = {}
	queries_before = driver.path_queries
	var abandoned_before := driver.abandoned_paths
	for tick in range(240):
		await frames(1)
		if tick % 15 == 0:
			driver.plan(2105 + tick)
			view = AIDebugState.read(driver, 2105 + tick)
			statuses[view.navigation] = true
		if driver.decisions.state == ObservationDecisions.State.RESUME:
			break
	expect(statuses.has("Blocked") and statuses.has("Recovering"),
		"real physical stall and finite retries surface as blocked and recovering")
	expect(view.state == "Resume" and view.navigation == "Waiting"
		and driver.abandoned_paths > abandoned_before and driver.path_queries - queries_before <= 2,
		"bounded recovery ends in resume without diagnostic-induced path queries")
	expect(actor.position.z < 7.5, "blocked-route diagnostics preserve solid collision")
	world.queue_free()
	await frames(3)
	print("Stage3B2: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
