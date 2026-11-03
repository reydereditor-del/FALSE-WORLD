class_name CharacterMotor
extends CharacterBody3D
## Shared world-space movement commands; no keyboard, camera, or AI dependencies.

@export_range(0.1, 20.0) var move_speed: float = 4.0
@export_range(0.1, 50.0) var gravity: float = 18.0
@export_range(0.0, 12.0) var facing_turn_speed: float = 0.0
var _move_intent: Vector3 = Vector3.ZERO
var _facing_intent: Vector3 = Vector3.ZERO
var has_facing_intent: bool = false


func set_facing_intent(direction: Vector3) -> void:
	var horizontal := Vector3(direction.x, 0.0, direction.z)
	if horizontal.length_squared() > 0.001:
		_facing_intent = horizontal.normalized()
		has_facing_intent = true


func set_move_intent(direction: Vector3) -> void:
	_move_intent = Vector3(direction.x, 0.0, direction.z).limit_length(1.0)


func _physics_process(delta: float) -> void:
	velocity.x = _move_intent.x * move_speed
	velocity.z = _move_intent.z * move_speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	var facing := _facing_intent if has_facing_intent else _move_intent
	if facing.length_squared() > 0.001:
		var target_yaw := atan2(-facing.x, -facing.z)
		if facing_turn_speed > 0.0:
			$Visual.rotation.y = rotate_toward($Visual.rotation.y, target_yaw, facing_turn_speed * delta)
		else:
			$Visual.rotation.y = target_yaw
