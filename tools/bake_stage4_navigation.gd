extends SceneTree
## Stage 4-only local bake includes component/control panel; all fallback resources are preserved.

func _initialize() -> void:
	call_deferred("bake")


func bake() -> void:
	var world := load("res://scenes/stage4/signal_loop.tscn").instantiate() as Node3D
	root.add_child(world)
	for i in range(3):
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
	var result := ResourceSaver.save(mesh, "res://scenes/stage4/station_navigation.tres")
	print("Stage4 navigation: ", mesh.get_polygon_count(), " polygons; save ", result)
	world.queue_free()
	for i in range(4):
		await physics_frame
		await process_frame
	quit(0 if result == OK and mesh.get_polygon_count() > 0 else 1)
