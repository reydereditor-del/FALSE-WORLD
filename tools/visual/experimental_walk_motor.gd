extends CharacterMotor
## Preview-only elliptical speed envelope, measured in the intended facing frame.
var backward_speed:=.9
var lateral_speed:=.65
var facing_yaw:=0.0
var directional_limit:=4.0
func _physics_process(delta: float) -> void:
	var original:=move_speed
	var direction:=Basis(Vector3.UP,facing_yaw).inverse()*_move_intent
	if direction.length()>.001:
		direction=direction.normalized()
		var longitudinal:=backward_speed if direction.z>0 else original
		directional_limit=1.0/sqrt(pow(direction.x/lateral_speed,2)+pow(direction.z/longitudinal,2))
		move_speed=directional_limit
	super(delta)
	move_speed=original
