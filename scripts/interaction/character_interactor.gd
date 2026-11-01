class_name CharacterInteractor
extends Node
## Replaceable control sources submit held/released intent; no input polling here.

@export var target: WorkTarget
@onready var actor: Node3D = get_parent() as Node3D


func step(requested: bool, delta: float) -> void:
	if not is_instance_valid(target):
		return
	if not requested:
		target.cancel(actor)
		return
	if target.begin(actor):
		target.advance(actor, delta)
	else:
		target.cancel(actor)


func _exit_tree() -> void:
	if is_instance_valid(target):
		target.cancel(actor)
