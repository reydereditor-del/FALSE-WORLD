extends "res://scripts/ai/stage3a_local.gd"
## Only static authored destinations are passed to exploration planners.

@export_range(0.5, 8.0) var agent_turn_speed: float = 3.5
@export_range(1.0, 12.0) var agent_steering_response: float = 5.0
@export_range(0, 180) var minimum_pause_ticks: int = 45
@export_range(180, 600) var maximum_pause_ticks: int = 180
var sites: Array[Dictionary] = []


func _ready() -> void:
	for marker in $Destinations.get_children():
		if sites.size() >= 16:
			break
		sites.append({"id": StringName(marker.name), "position": marker.global_position,
			"area": StringName(marker.get_meta("area")), "kind": StringName(marker.get_meta("kind"))})
	start_positions = PackedVector3Array([Vector3(-8, 0.1, 12), Vector3(12, 0.1, 6), Vector3(-12, 0.1, -12)])
	patrol_points.clear()
	for site in sites:
		patrol_points.append(site.position)
	super._ready()


func create_controller(_index: int) -> WaypointController:
	var controller := ExplorationController.new()
	controller.choices.sites = sites.duplicate(true)
	controller.choices.minimum_wait_ticks = minimum_pause_ticks
	controller.choices.maximum_wait_ticks = maximum_pause_ticks
	controller.turn_speed = agent_turn_speed
	controller.steering_response = agent_steering_response
	return controller
