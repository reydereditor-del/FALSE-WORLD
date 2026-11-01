extends Node3D
## Small local composition and deterministic scheduling. No full-game systems.

const ACTOR := preload("res://scenes/character/shared_character.tscn")
@export var simulation_seed: int = 431
@export_range(3, 120) var update_interval_ticks: int = 15
@export_range(1, 300) var report_delay_ticks: int = 30
@export_range(1, 1200) var memory_freshness_ticks: int = 300
@export_range(0.1, 32.0) var perception_range: float = 8.0
@export_range(10.0, 180.0) var perception_fov: float = 120.0
@export_range(1, 64) var memory_capacity: int = 8
@export_range(1, 64) var report_queue_capacity: int = 12
var actors: Dictionary = {}
var sensors: Array[LocalPerception] = []
var controllers: Array[WaypointController] = []
var channel := ObservedFactChannel.new()
var simulation_tick: int = 0
var max_sensors_per_tick: int = 0


func _ready() -> void:
	process_physics_priority = -20
	actors[&"F11"] = $Character
	var ids: Array[StringName] = [&"K72", &"B14", &"D09"]
	var starts := [Vector3(-6, 0.1, -5), Vector3(6, 0.1, -5), Vector3(6, 0.1, 5)]
	var route := PackedVector3Array([Vector3(-6, 0, -5), Vector3(6, 0, -5),
		Vector3(6, 0, 5), Vector3(-6, 0, 5)])
	channel.delay_ticks = report_delay_ticks
	channel.capacity = report_queue_capacity
	for index in range(3):
		var actor := ACTOR.instantiate() as CharacterMotor
		actor.name = String(ids[index])
		actor.position = starts[index]
		add_child(actor)
		actors[ids[index]] = actor
		var navigator := NavigationAgent3D.new()
		navigator.name = "NavigationAgent3D"
		navigator.path_desired_distance = 0.3
		navigator.target_desired_distance = 0.35
		navigator.radius = 0.35
		navigator.height = 1.8
		navigator.max_speed = actor.move_speed
		navigator.avoidance_enabled = false
		actor.add_child(navigator)
		var controller := WaypointController.new()
		controller.motor = actor
		controller.navigator = navigator
		controller.waypoints = route
		controller.seed_value = simulation_seed + index
		controller.update_interval_ticks = update_interval_ticks
		controller.schedule_offset = floori(float(index * update_interval_ticks) / 3.0)
		actor.add_child(controller)
		controller.initialize()
		controllers.append(controller)
		var sensor := LocalPerception.new()
		sensor.actor = actor
		sensor.observer_id = ids[index]
		sensor.memory = LocalMemory.new()
		sensor.memory.freshness_ticks = memory_freshness_ticks
		sensor.memory.capacity = memory_capacity
		sensor.range_units = perception_range
		sensor.field_of_view_degrees = perception_fov
		actor.add_child(sensor)
		sensors.append(sensor)
	for index in range(3):
		sensors[index].candidates = actors.duplicate()
		channel.register(sensors[index], ids[(index + 1) % 3], sensors[index].memory)


func _physics_process(_delta: float) -> void:
	simulation_tick += 1
	channel.advance(simulation_tick)
	var sampled: int = 0
	for index in range(3):
		var controller := controllers[index]
		if (simulation_tick + controller.schedule_offset) % update_interval_ticks != 0:
			continue
		sensors[index].memory.expire(simulation_tick)
		sensors[index].sample(simulation_tick)
		controller.plan(simulation_tick)
		sampled += 1
	max_sensors_per_tick = maxi(max_sensors_per_tick, sampled)
