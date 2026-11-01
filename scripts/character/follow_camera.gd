class_name FollowCamera
extends Node3D
## Yaw-only movement frame, clamped orbit pitch, collision-retracting spring arm.

@export_range(0.0001, 0.02) var mouse_sensitivity: float = 0.003
@export_range(-85.0, -10.0) var minimum_pitch_degrees: float = -65.0
@export_range(0.0, 70.0) var maximum_pitch_degrees: float = 20.0
@onready var pitch_pivot: Node3D = $Pitch
@onready var spring: SpringArm3D = $Pitch/SpringArm3D


func _ready() -> void:
	var body := get_parent() as CollisionObject3D
	if body:
		spring.add_excluded_object(body.get_rid())


func orbit(relative_motion: Vector2) -> void:
	rotation.y = wrapf(rotation.y - relative_motion.x * mouse_sensitivity, -PI, PI)
	pitch_pivot.rotation.x = clampf(
		pitch_pivot.rotation.x - relative_motion.y * mouse_sensitivity,
		deg_to_rad(minimum_pitch_degrees), deg_to_rad(maximum_pitch_degrees)
	)


func movement_direction(input_axis: Vector2) -> Vector3:
	return global_basis * Vector3(input_axis.x, 0.0, input_axis.y)
