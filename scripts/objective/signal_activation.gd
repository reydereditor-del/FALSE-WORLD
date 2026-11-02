class_name SignalActivation
extends WorkTarget
## Reuse WorkTarget's progress/lock/interrupt semantics; install only when hold completes.

var objective: SignalObjective
var _actor_id: int = 0


func _ready() -> void:
	super._ready()
	completed.connect(_send_call)


func begin(actor: Node3D) -> bool:
	if objective == null or not objective.can_activate(actor.get_instance_id()):
		return false
	if not super.begin(actor):
		return false
	_actor_id = actor.get_instance_id()
	return true


func advance(actor: Node3D, delta: float) -> void:
	if objective == null or not objective.can_activate(actor.get_instance_id()):
		cancel(actor)
		return
	super.advance(actor, delta)


func _send_call() -> void:
	objective.send_call(_actor_id)


func rearm_after_empty_arrival() -> void:
	if objective.phase != SignalObjective.Phase.READY or not objective.installed:
		return
	progress_seconds = 0.0
	is_complete = false
	_worker = null
	_update_lever()
