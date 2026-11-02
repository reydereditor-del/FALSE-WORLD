extends "res://scripts/ai/stage3b1_local.gd"
## Local report assessment only; the existing selective relay and sensing are retained.

@export_range(30, 300) var coordination_report_age_ticks: int = 120
@export_range(0.5, 3.0) var coordination_area_radius: float = 1.5
@export_range(0.5, 4.0) var coordination_nearby_distance: float = 2.5
@export_range(0, 120) var coordination_reserve_ticks: int = 30


func create_controller(index: int) -> WaypointController:
	var controller := super.create_controller(index) as ObservationController
	controller.decisions.coordination = ReportCoordination.new()
	controller.decisions.coordination.maximum_report_age_ticks = coordination_report_age_ticks
	controller.decisions.coordination.area_radius = coordination_area_radius
	controller.decisions.coordination.nearby_distance = coordination_nearby_distance
	controller.decisions.coordination.reserve_ticks = coordination_reserve_ticks
	return controller
