extends Node3D
## Explicit local composition; no objective state is injected into AI or its sensor candidates.

var objective := SignalObjective.new()
var player: CharacterMotor
var interactor: CharacterInteractor
var pickup: SignalComponentPickup
var device: SignalActivation
var old_lever: WorkTarget
var focus_target: WorkTarget
var feedback: Label
var _restart_pending: bool = false


func _ready() -> void:
	process_physics_priority = -30
	var area := get_parent().get_node("LocalArea")
	player = area.get_node("Character")
	interactor = player.get_node("Interactor")
	old_lever = area.get_node("Lever")
	pickup = $Component
	device = $Device
	pickup.objective = objective
	device.objective = objective
	objective.changed.connect(_state_changed)
	# A lightweight local-player message only; no roster, hidden roles or global AI state.
	var layer := CanvasLayer.new()
	layer.name = "ObjectiveFeedback"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	panel.offset_left = 12
	panel.offset_right = 800
	panel.offset_top = -140
	panel.offset_bottom = -12
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback = Label.new()
	feedback.add_theme_font_size_override("font_size", 16)
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(feedback)
	panel.add_child(margin)
	layer.add_child(panel)
	var timer := Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_refresh_feedback)
	add_child(timer)
	timer.start()
	_state_changed()
	_refresh_feedback()


func _physics_process(delta: float) -> void:
	var next_target: WorkTarget
	var distance := INF
	var candidates: Array[WorkTarget] = [device, old_lever]
	if objective.phase == SignalObjective.Phase.SEARCH:
		candidates.append(pickup)
	for target in candidates:
		if not target.can_reach(player):
			continue
		var measured := player.global_position.distance_squared_to(target.global_position)
		if measured < distance:
			distance = measured
			next_target = target
	if interactor.target != next_target:
		if is_instance_valid(interactor.target):
			interactor.target.cancel(player)
		interactor.target = next_target
	focus_target = next_target
	objective.advance_time(delta, player_in_yard())


func player_in_yard() -> bool:
	var point: Vector3 = $ExtractionYard.to_local(player.global_position + Vector3.UP * 0.9)
	var size: Vector3 = $ExtractionYard/Collision.shape.size
	return AABB(-size / 2, size).has_point(point)


func _state_changed() -> void:
	$InstalledModule.visible = objective.installed
	if objective.phase == SignalObjective.Phase.READY:
		device.rearm_after_empty_arrival()
	_refresh_feedback()


func _refresh_feedback() -> void:
	if feedback == null:
		return
	var message := ""
	match objective.phase:
		SignalObjective.Phase.SEARCH:
			message = "Find the service module on the storehouse workbench."
		SignalObjective.Phase.CARRYING:
			message = "Module carried. Bring it to the signal cabinet beside the radio mast."
		SignalObjective.Phase.READY:
			message = "Empty arrival. Module stays installed; return to the cabinet to call again."
		SignalObjective.Phase.WAITING:
			message = "Signal sent. Wait in the marked yard; the call continues if you leave."
			if player_in_yard() or focus_target == device:
				message += "\nArrival in %.1f s." % objective.remaining
		SignalObjective.Phase.SUCCESS:
			message = "PROTOTYPE EXTRACTION COMPLETE" if objective.banner_remaining > 0 else "Prototype run complete."
	if focus_target == pickup and objective.phase == SignalObjective.Phase.SEARCH:
		message += "\nHold E: collect module."
	elif focus_target == device:
		if objective.can_activate(player.get_instance_id()):
			message += "\nHold E: send signal %d%% (release/move away to interrupt)." % roundi(device.progress_seconds / device.duration_seconds * 100)
		elif objective.phase == SignalObjective.Phase.SEARCH:
			message += "\nThis cabinet needs the service module."
	elif focus_target == old_lever:
		message += "\nE: original M1 lever test (not the signal device)."
	feedback.text = "STAGE 4 | single-route local prototype\n" + message + "\nR: restart prototype | WASD + mouse | Esc: release cursor"


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event.physical_keycode == KEY_R or event.keycode == KEY_R):
		request_restart()
		get_viewport().set_input_as_handled()


func request_restart() -> void:
	if _restart_pending:
		return
	_restart_pending = true
	interactor.step(false, 0.0)
	get_tree().call_deferred("reload_current_scene")
