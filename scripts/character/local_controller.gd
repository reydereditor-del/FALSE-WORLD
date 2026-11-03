extends Node
## The only keyboard/mouse adapter. Replacing it does not change physical rules.

@export var motor: CharacterMotor
@export var camera_rig: FollowCamera
@export var interactor: CharacterInteractor
@export var camera_facing_locomotion: bool = false
var _controls_active: bool = true


func _ready() -> void:
	process_physics_priority = -10
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		_release_controls()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_controls_active = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and _controls_active:
		camera_rig.orbit(event.relative)


func _physics_process(delta: float) -> void:
	if not _controls_active:
		motor.set_move_intent(Vector3.ZERO)
		interactor.step(false, delta)
		return
	var axis := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if camera_facing_locomotion and axis.length_squared() > 0.001:
		motor.set_facing_intent(camera_rig.movement_direction(Vector2(0, -1)))
	motor.set_move_intent(camera_rig.movement_direction(axis))
	interactor.step(Input.is_action_pressed("interact"), delta)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		_release_controls()


func _release_controls() -> void:
	_controls_active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	motor.set_move_intent(Vector3.ZERO)
	interactor.step(false, 0.0)
