class_name WaypointController
extends Node
## Patrol only. No human target reference or dialogue/strategy implementation.

var motor: CharacterMotor
var navigator: NavigationAgent3D
var waypoints: PackedVector3Array
var seed_value: int = 1
var update_interval_ticks: int = 15
var schedule_offset: int = 0
var index: int = 0
var repath_attempts: int = 0
var abandoned_paths: int = 0
var _last_position: Vector3
var _stalled_ticks: int = 0
var _started: bool = false


func initialize() -> void:
	process_physics_priority = -10
	_started = false
	_stalled_ticks = 0
	repath_attempts = 0
	motor.set_move_intent(Vector3.ZERO)
	if waypoints.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	index = rng.randi_range(0, waypoints.size() - 1)
	_last_position = motor.global_position


func plan(_now: int) -> void:
	if waypoints.is_empty():
		return
	if NavigationServer3D.map_get_iteration_id(navigator.get_navigation_map()) == 0:
		return
	if not _started:
		_started = true
		navigator.target_position = waypoints[index]
		return
	if navigator.is_navigation_finished():
		index = (index + 1) % waypoints.size()
		navigator.target_position = waypoints[index]
		_stalled_ticks = 0
		repath_attempts = 0
	elif motor.global_position.distance_to(_last_position) < 0.05:
		_stalled_ticks += update_interval_ticks
		if _stalled_ticks >= 120:
			_stalled_ticks = 0
			if repath_attempts < 2:
				repath_attempts += 1
				navigator.target_position = waypoints[index]
			else:
				abandoned_paths += 1
				index = (index + 1) % waypoints.size()
				navigator.target_position = waypoints[index]
				repath_attempts = 0
	else:
		_stalled_ticks = 0
	_last_position = motor.global_position


func _physics_process(_delta: float) -> void:
	if not _started or NavigationServer3D.map_get_iteration_id(navigator.get_navigation_map()) == 0:
		motor.set_move_intent(Vector3.ZERO)
		return
	if navigator.is_navigation_finished():
		motor.set_move_intent(Vector3.ZERO)
		return
	var direction := navigator.get_next_path_position() - motor.global_position
	direction.y = 0.0
	motor.set_move_intent(direction.normalized())
