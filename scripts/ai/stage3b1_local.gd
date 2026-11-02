extends "res://scripts/ai/stage3a1_local.gd"
## Composition wires only each agent's private memory to its decision adapter.

@export_range(15, 180) var minimum_observe_ticks: int = 45
@export_range(15, 300) var maximum_observe_ticks: int = 90
@export_range(30, 600) var investigation_timeout_ticks: int = 240
@export_range(30, 600) var decision_cooldown_ticks: int = 180
@export_range(60, 1800) var subject_cooldown_ticks: int = 900
@export_range(1.0, 20.0) var investigation_range: float = 12.0


func _ready() -> void:
	super._ready()
	var peers: Array[StringName] = []
	for sensor in sensors:
		peers.append(sensor.observer_id)
	for index in range(controllers.size()):
		var controller := controllers[index] as ObservationController
		controller.memory = sensors[index].memory
		controller.decisions.teammate_ids = peers.duplicate()
		controller.decisions.freshness_ticks = memory_freshness_ticks
		controller.decisions.minimum_observe_ticks = minimum_observe_ticks
		controller.decisions.maximum_observe_ticks = maximum_observe_ticks
		controller.decisions.investigation_timeout_ticks = investigation_timeout_ticks
		controller.decisions.cooldown_ticks = decision_cooldown_ticks
		controller.decisions.subject_cooldown_ticks = subject_cooldown_ticks
		controller.decisions.maximum_distance = investigation_range


func create_controller(_index: int) -> WaypointController:
	var controller := ObservationController.new()
	controller.choices.sites = sites.duplicate(true)
	controller.choices.minimum_wait_ticks = minimum_pause_ticks
	controller.choices.maximum_wait_ticks = maximum_pause_ticks
	controller.turn_speed = agent_turn_speed
	controller.steering_response = agent_steering_response
	return controller
