extends SceneTree
## Rebuild after changing static geometry in the inherited M1 yard; no dependencies.

func _initialize() -> void:
	call_deferred("_bake")


func _bake() -> void:
	var yard := load("res://scenes/prototype/m1_graybox.tscn").instantiate() as Node3D
	root.add_child(yard)
	var mesh := NavigationMesh.new()
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_collision_mask = 1
	mesh.agent_radius = 0.5
	mesh.agent_height = 1.8
	mesh.agent_max_climb = 0.2
	mesh.agent_max_slope = 45.0
	mesh.cell_size = 0.25
	mesh.cell_height = 0.1
	var source := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh, source, yard)
	NavigationServer3D.bake_from_source_geometry_data(mesh, source)
	if mesh.get_polygon_count() == 0:
		push_error("Navigation bake produced no polygons")
		quit(1)
		return
	var result := ResourceSaver.save(mesh, "res://scenes/prototype/stage3a_navigation.tres")
	print("Navigation bake: ", mesh.get_polygon_count(), " polygons; save status ", result)
	yard.queue_free()
	await process_frame
	quit(0 if result == OK else 1)
