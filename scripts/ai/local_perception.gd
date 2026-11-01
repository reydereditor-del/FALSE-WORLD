class_name LocalPerception
extends Node
## Privileged sensing adapter. Only successful range/cone/LOS samples emit facts.

signal observed(fact: Dictionary)
var observer_id: StringName
var actor: CharacterMotor
var candidates: Dictionary = {}
var memory: LocalMemory
var range_units: float = 8.0
var field_of_view_degrees: float = 120.0
var max_candidates: int = 4
var samples_taken: int = 0


func sample(now: int) -> void:
	samples_taken += 1
	var origin := actor.global_position + Vector3.UP * 1.4
	var forward: Vector3 = -actor.get_node("Visual").global_basis.z
	var checked: int = 0
	for subject: StringName in candidates:
		if checked >= max_candidates:
			break
		checked += 1
		var target := candidates[subject] as CharacterMotor
		if target == actor or not is_instance_valid(target):
			continue
		var point := target.global_position + Vector3.UP * 1.2
		var direction := point - origin
		if direction.length() > range_units:
			continue
		if forward.dot(direction.normalized()) < cos(deg_to_rad(field_of_view_degrees * 0.5)):
			continue
		var query := PhysicsRayQueryParameters3D.create(origin, point, 1, [actor.get_rid()])
		var hit := actor.get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty() and hit.collider != target:
			continue
		var fact := {"observer": observer_id, "subject": subject, "event": &"seen",
			"position": target.global_position, "tick": now, "confidence": 1.0, "source": &"vision"}
		if memory.remember(fact, now):
			observed.emit(fact.duplicate(true))
