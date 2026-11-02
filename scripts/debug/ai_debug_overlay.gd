class_name AIDebugOverlay
extends CanvasLayer
## Editor-binary-only diagnostics. Disabled by default; no frame polling or 3D markers.

var enabled: bool = false
var refresh_count: int = 0
var _panel: PanelContainer
var _label: Label
var _timer: Timer


static func developer_build(editor_feature: bool, debug_build: bool) -> bool:
	return editor_feature and debug_build


func _ready() -> void:
	layer = 100
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_key_input(developer_build(OS.has_feature("editor"), OS.is_debug_build()))


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and (event.physical_keycode == KEY_F3 or event.keycode == KEY_F3):
		set_enabled(not enabled)
		get_viewport().set_input_as_handled()


func set_enabled(value: bool) -> void:
	enabled = value and developer_build(OS.has_feature("editor"), OS.is_debug_build())
	if not enabled:
		if is_instance_valid(_panel):
			_panel.hide()
			_panel.queue_free()
		if is_instance_valid(_timer):
			_timer.stop()
			_timer.queue_free()
		_panel = null
		_label = null
		_timer = null
		return
	if is_instance_valid(_panel):
		return
	_panel = PanelContainer.new()
	_panel.position = Vector2(12, 12)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	_panel.add_child(margin)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 14)
	margin.add_child(_label)
	add_child(_panel)
	_timer = Timer.new()
	_timer.wait_time = 0.1
	_timer.timeout.connect(_refresh)
	add_child(_timer)
	_timer.start()
	_refresh()


func _refresh() -> void:
	if not enabled or not is_instance_valid(_label):
		return
	var world := get_parent()
	var blocks := PackedStringArray(["DEVELOPER AI | F3 hide | tick %d" % world.simulation_tick])
	# Only own controller/memory views; do not read sensors, actor registry or human nodes.
	for index in range(mini(3, world.controllers.size())):
		var controller := world.controllers[index] as ObservationController
		blocks.append(AIDebugState.describe(AIDebugState.read(controller, world.simulation_tick),
			Engine.physics_ticks_per_second))
	_label.text = "\n\n".join(blocks)
	refresh_count += 1
