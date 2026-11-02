class_name ExplorationController
extends WaypointController
## Travel / wait-observe foundation. Candidate locations contain no human state.

var choices := ExplorationChoices.new()
var turn_speed: float = 3.5
var steering_response: float = 5.0
var waiting: bool = true
var wait_until: int = 0
var selections: int = 0
var failed_destinations: int = 0
var path_queries: int = 0
var stall_timeout_ticks: int = 120
var _intent := Vector3.ZERO
var _goal := Vector3.ZERO


func initialize() -> void:
	process_physics_priority = -10
	choices.initialize(seed_value)
	motor.facing_turn_speed = turn_speed
	_intent = Vector3.ZERO
	motor.set_move_intent(_intent)
	waiting = true
	wait_until = choices.initial_pause()
	_started = false
	_last_position = motor.global_position
	_stalled_ticks = 0
	repath_attempts = 0


func plan(now: int) -> void:
	var map := navigator.get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(map) == 0:
		return
	if waiting:
		if now < wait_until:
			return
		# At most two candidate path checks per staggered decision update.
		for attempt in range(2):
			index = choices.choose(motor.global_position, now)
			if index < 0:
				wait_until = now + 60
				return
			var target: Vector3 = choices.sites[index].position
			if not try_destination(target):
				choices.reject(index, now)
				failed_destinations += 1
				continue
			selections += 1
			return
		wait_until = now + 60
		return
	if motor.global_position.distance_to(_goal) < 0.7:
		_arrive(now)
	elif navigator.is_navigation_finished():
		_abandon(now)
	elif motor.global_position.distance_to(_last_position) < 0.05:
		_stalled_ticks += update_interval_ticks
		if _stalled_ticks >= stall_timeout_ticks:
			_stalled_ticks = 0
			if repath_attempts < 2:
				repath_attempts += 1
				navigator.target_position = _goal
				path_queries += 1
			else:
				_abandon(now)
	else:
		_stalled_ticks = 0
	_last_position = motor.global_position


func try_destination(target: Vector3) -> bool:
	var map := navigator.get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(map) == 0:
		return false
	var nearest := NavigationServer3D.map_get_closest_point(map, target)
	path_queries += 1
	var path := NavigationServer3D.map_get_path(map, motor.global_position, nearest, true)
	if nearest.distance_to(target) > 0.75 or path.is_empty() or path[-1].distance_to(nearest) > 0.5:
		return false
	_goal = nearest
	navigator.target_position = _goal
	waiting = false
	_started = true
	_stalled_ticks = 0
	repath_attempts = 0
	_last_position = motor.global_position
	return true


func _arrive(now: int) -> void:
	waiting = true
	wait_until = now + choices.arrived(index)


func _abandon(now: int) -> void:
	choices.reject(index, now)
	abandoned_paths += 1
	waiting = true
	wait_until = now + 30


func _physics_process(delta: float) -> void:
	var desired := Vector3.ZERO
	if _started and not waiting and not navigator.is_navigation_finished():
		var direction := navigator.get_next_path_position() - motor.global_position
		direction.y = 0.0
		var distance := motor.global_position.distance_to(_goal)
		# Ease into an arrival instead of repeatedly stopping at intermediate path nodes.
		desired = direction.normalized() * clampf(distance / 1.2, 0.0, 1.0)
	_intent = _intent.move_toward(desired, steering_response * delta)
	motor.set_move_intent(_intent)
