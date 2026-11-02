class_name SignalObjective
extends RefCounted
## One local prototype component/call. No Nodes, input, roles, AI, inventory framework or networking.

signal changed

enum Phase { SEARCH, CARRYING, READY, WAITING, SUCCESS }
var phase: Phase = Phase.SEARCH
var carrier_id: int = 0
var installed: bool = false
var wait_seconds: float = 5.0
var remaining: float = 0.0
var banner_seconds: float = 6.0
var banner_remaining: float = 0.0
var calls_sent: int = 0
var missed_arrivals: int = 0
var successes: int = 0


func collect(actor_id: int) -> bool:
	if phase != Phase.SEARCH or actor_id <= 0:
		return false
	carrier_id = actor_id
	phase = Phase.CARRYING
	changed.emit()
	return true


func can_activate(actor_id: int) -> bool:
	return actor_id > 0 and ((phase == Phase.CARRYING and carrier_id == actor_id) or
		(phase == Phase.READY and installed))


func send_call(actor_id: int) -> bool:
	if not can_activate(actor_id):
		return false
	installed = true
	carrier_id = 0
	phase = Phase.WAITING
	remaining = maxf(0.0, wait_seconds)
	calls_sent += 1
	changed.emit()
	return true


func advance_time(delta: float, player_in_yard: bool) -> void:
	if not is_finite(delta) or delta <= 0.0:
		return
	if phase == Phase.WAITING:
		remaining = maxf(0.0, remaining - delta)
		if remaining == 0.0:
			if player_in_yard:
				phase = Phase.SUCCESS
				successes += 1
				banner_remaining = banner_seconds
			else:
				phase = Phase.READY
				missed_arrivals += 1
			changed.emit()
	elif phase == Phase.SUCCESS:
		banner_remaining = maxf(0.0, banner_remaining - delta)
