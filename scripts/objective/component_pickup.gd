class_name SignalComponentPickup
extends WorkTarget
## Existing one-worker/range/LOS/hold interaction; ownership transfers once at completion.

var objective: SignalObjective
var _actor_id: int = 0


func _ready() -> void:
	super._ready()
	completed.connect(_collected)


func begin(actor: Node3D) -> bool:
	if objective == null or objective.phase != SignalObjective.Phase.SEARCH:
		return false
	if not super.begin(actor):
		return false
	_actor_id = actor.get_instance_id()
	return true


func _collected() -> void:
	if objective.collect(_actor_id):
		hide()
		collision_layer = 0
		$Collision.set_deferred("disabled", true)
