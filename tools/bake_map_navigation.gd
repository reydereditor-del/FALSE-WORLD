extends SceneTree
## Bake only the 90x90 m station quarter, never the whole 1 km footprint.

func _initialize() -> void:
	call_deferred("bake")


func bake() -> void:
	var world := load("res://scenes/world/map_foundation.tscn").instantiate() as Node3D
	root.add_child(world)
	for frame in range(3):
		await physics_frame
		await process_frame
	var mesh := NavigationMesh.new()
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_collision_mask = 1
	mesh.filter_baking_aabb = AABB(Vector3(175, -2, 95), Vector3(90, 14, 90))
	mesh.agent_radius = 0.5
	mesh.agent_height = 1.8
	mesh.agent_max_climb = 0.2
	mesh.agent_max_slope = 40.0
	mesh.cell_size = 0.25
	mesh.cell_height = 0.1
	var source := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh, source, world)
	NavigationServer3D.bake_from_source_geometry_data(mesh, source)
	if mesh.get_polygon_count() == 0:
		push_error("Empty map navigation bake")
		quit(1)
		return
	var result := ResourceSaver.save(mesh, "res://scenes/world/station_navigation.tres")
	print("Map navigation: ", mesh.get_polygon_count(), " polygons; status ", result)
	world.queue_free()
	for frame in range(3):
		await physics_frame
		await process_frame
	quit(0 if result == OK else 1)
