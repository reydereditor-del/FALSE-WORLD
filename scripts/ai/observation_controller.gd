class_name ObservationController
extends ExplorationController
## Reuses the existing path follower, steering, shared physics and finite recovery.

var memory: LocalMemory
var decisions := ObservationDecisions.new()
var _next_plan_tick: int = 0
var _arrived: bool = false
var _failed: bool = false


func initialize() -> void:
	super.initialize()
	decisions.interval_ticks = update_interval_ticks
	if decisions.coordination != null:
		decisions.coordination.move_speed = motor.move_speed
		decisions.coordination.ticks_per_second = Engine.physics_ticks_per_second
	decisions.initialize(seed_value)
	_next_plan_tick = 0
	_arrived = false
	_failed = false


func plan(now: int) -> void:
	if now < _next_plan_tick or memory == null:
		return
	_next_plan_tick = now + maxi(1, update_interval_ticks)
	var previous := decisions.state
	decisions.step(now, memory.snapshot(now), motor.global_position, _arrived, _failed)
	if previous != decisions.state:
		waiting = true
		if decisions.state == ObservationDecisions.State.INVESTIGATE:
			_arrived = false
			var path_limit: float = INF
			if decisions.coordination != null and decisions.evidence.source == &"team_report":
				path_limit = decisions.coordination.travel_limit(now, decisions.freshness_ticks, decisions.investigation_timeout_ticks)
			_failed = not try_destination(decisions.investigation_destination, path_limit)
			return
		if decisions.state == ObservationDecisions.State.EXPLORE:
			_started = false
			wait_until = now
	match decisions.state:
		ObservationDecisions.State.EXPLORE:
			super.plan(now)
		ObservationDecisions.State.INVESTIGATE:
			if not _arrived and not _failed:
				super.plan(now)
		_:
			waiting = true


func _arrive(now: int) -> void:
	if decisions.state == ObservationDecisions.State.INVESTIGATE:
		_arrived = true
		waiting = true
	else:
		super._arrive(now)


func _abandon(now: int) -> void:
	if decisions.state == ObservationDecisions.State.INVESTIGATE:
		_failed = true
		waiting = true
		abandoned_paths += 1
	else:
		super._abandon(now)
