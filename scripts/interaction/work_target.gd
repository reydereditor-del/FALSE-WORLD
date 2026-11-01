class_name WorkTarget
extends StaticBody3D
## One worker; progress belongs to the target and survives cancellation in this scene.

signal started
signal canceled
signal progress_changed(fraction: float)
signal completed

# Prototype tuning, not finalized game balance.
@export_range(0.1, 30.0) var duration_seconds: float = 3.0
@export_range(0.1, 5.0) var interaction_range: float = 2.2
var progress_seconds: float = 0.0
var is_complete: bool = false
var _worker: Node3D
@onready var lever_pivot: Node3D = $LeverPivot


func _ready() -> void:
	_update_lever()


func can_reach(actor: Node3D) -> bool:
	if not is_instance_valid(actor) or not actor.is_inside_tree():
		return false
	var origin := actor.global_position + Vector3.UP
	if origin.distance_to(global_position) > interaction_range:
		return false
	var query := PhysicsRayQueryParameters3D.create(origin, global_position, collision_mask)
	if actor is CollisionObject3D:
		query.exclude = [actor.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.collider == self


func begin(actor: Node3D) -> bool:
	if is_complete or not can_reach(actor):
		return false
	if is_instance_valid(_worker):
		if not can_reach(_worker):
			cancel(_worker)
		else:
			return _worker == actor
	_worker = actor
	started.emit()
	return true


func advance(actor: Node3D, delta: float) -> void:
	if is_complete or not is_instance_valid(_worker) or _worker != actor:
		return
	if not can_reach(actor):
		cancel(actor)
		return
	progress_seconds = minf(progress_seconds + maxf(delta, 0.0), duration_seconds)
	_update_lever()
	progress_changed.emit(progress_seconds / duration_seconds)
	if progress_seconds >= duration_seconds:
		is_complete = true
		_worker = null
		completed.emit()


func cancel(actor: Node3D) -> void:
	if is_instance_valid(_worker) and _worker == actor:
		_worker = null
		canceled.emit()


func _update_lever() -> void:
	lever_pivot.rotation.z = lerpf(-PI / 4.0, PI / 4.0, progress_seconds / duration_seconds)
