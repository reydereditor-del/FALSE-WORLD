extends SceneTree
## Deterministic authoring tool. Saves real editable geometry; no runtime world generation.

const OUTPUT := "res://scenes/world/map_foundation.tscn"
var world: Node3D
var material_cache: Dictionary = {}


func _initialize() -> void:
	call_deferred("build")


func material(color: Color) -> StandardMaterial3D:
	if not material_cache.has(color):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 1.0
		material_cache[color] = mat
	return material_cache[color]


func group(parent: Node, label: String) -> Node3D:
	var node := Node3D.new()
	node.name = label
	parent.add_child(node)
	return node


func box(parent: Node, label: String, center: Vector3, size: Vector3, color: Color, solid: bool = true) -> Node3D:
	var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
	node.name = label
	node.position = center
	parent.add_child(node)
	var visual := MeshInstance3D.new()
	visual.name = "Mesh"
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material(color)
	visual.mesh = mesh
	node.add_child(visual)
	if solid:
		var collision := CollisionShape3D.new()
		collision.name = "Collision"
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		node.add_child(collision)
	return node


func signpost(parent: Node, label: String, x: float, z: float, text: String) -> void:
	var base := MapLayout.point(x, z)
	var node := group(parent, label)
	box(node, "Post", base + Vector3(0, 1.25, 0), Vector3(0.18, 2.5, 0.18), Color("71604a"))
	box(node, "Board", base + Vector3(0, 2.15, 0), Vector3(4.8, 1.25, 0.15), Color("283a38"))
	# Two readable faces, fixed in the world; no role markers or gameplay UI.
	for side in [1, -1]:
		var label3d := Label3D.new()
		label3d.name = "Text" + str(side)
		label3d.text = text
		label3d.font_size = 40
		label3d.pixel_size = 0.006
		label3d.position = base + Vector3(0, 2.15, side * 0.09)
		label3d.rotation.y = 0 if side == 1 else PI
		node.add_child(label3d)


func terrain() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(-500, 500, 20):
		for x in range(-500, 500, 20):
			var a := MapLayout.point(x, z)
			var b := MapLayout.point(x + 20, z)
			var c := MapLayout.point(x, z + 20)
			var d := MapLayout.point(x + 20, z + 20)
			var shade := Color("69735b") if a.y < 12 else Color("8b8c79")
			surface.set_color(shade)
			for vertex in [a, b, c, b, d, c]:
				surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh := surface.commit()
	var mat := material(Color.WHITE)
	mat.vertex_color_use_as_albedo = true
	mesh.surface_set_material(0, mat)
	var node := StaticBody3D.new()
	node.name = "Terrain"
	world.add_child(node)
	var visual := MeshInstance3D.new()
	visual.name = "Mesh"
	visual.mesh = mesh
	node.add_child(visual)
	var collision := CollisionShape3D.new()
	collision.name = "Collision"
	collision.shape = mesh.create_trimesh_shape()
	node.add_child(collision)
	var boundaries := group(world, "Bounds")
	for x in [-501.0, 501.0]:
		box(boundaries, "East" if x > 0 else "West", Vector3(x, 40, 0), Vector3(2, 100, 1004), Color("777b6b"))
	for z in [-501.0, 501.0]:
		box(boundaries, "South" if z > 0 else "North", Vector3(0, 40, z), Vector3(1000, 100, 2), Color("777b6b"))


func road(parent: Node, label: String, path: PackedVector3Array, width: float = 6.0) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for segment in range(1, path.size()):
		var start := path[segment - 1]
		var finish := path[segment]
		var direction := Vector3(finish.x - start.x, 0, finish.z - start.z).normalized()
		var side := Vector3(-direction.z, 0, direction.x) * width / 2.0
		var steps := ceili(start.distance_to(finish) / 2.0)
		for step in range(steps):
			var p := start.lerp(finish, float(step) / steps)
			var q := start.lerp(finish, float(step + 1) / steps)
			for vertex in [p - side, q - side, p + side, q - side, q + side, p + side]:
				vertex.y = MapLayout.height(vertex.x, vertex.z) + 0.06
				surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh := surface.commit()
	mesh.surface_set_material(0, material(Color("8b806b")))
	var visual := MeshInstance3D.new()
	visual.name = label
	visual.mesh = mesh
	parent.add_child(visual)


func shell(parent: Node, label: String, center: Vector3, size: Vector2, height_value: float = 4.5) -> void:
	var node := group(parent, label)
	# Two opposite 4 m entrances; flush terrain floors and no jump thresholds.
	var wall := Color("9a988b")
	var trim := Color("676d68")
	box(node, "West", center + Vector3(-size.x / 2, height_value / 2, 0), Vector3(0.6, height_value, size.y), wall)
	box(node, "East", center + Vector3(size.x / 2, height_value / 2, 0), Vector3(0.6, height_value, size.y), wall)
	for z in [-size.y / 2, size.y / 2]:
		for x in [-1, 1]:
			var span := (size.x - 4.0) / 2.0
			box(node, "DoorSide" + str(z) + str(x), center + Vector3(x * (2.0 + span / 2), height_value / 2, z), Vector3(span, height_value, 0.6), wall)
		box(node, "Lintel" + str(z), center + Vector3(0, height_value - 0.35, z), Vector3(4, 0.7, 0.6), trim)
	# Raised roof-edge fragments give the abandoned shells recognizable silhouettes.
	box(node, "BrokenRoof", center + Vector3(-size.x / 2 + 2, height_value, 0), Vector3(4, 0.25, size.y), trim)


func tree(parent: Node, index: int, x: float, z: float) -> void:
	var base := MapLayout.point(x, z)
	var node := group(parent, "Pine%03d" % index)
	box(node, "Trunk", base + Vector3(0, 2.5, 0), Vector3(0.8, 5, 0.8), Color("615647"))
	# Low solid crown also blocks physical sight rays; independent simple box collider.
	var crown := StaticBody3D.new()
	crown.name = "Crown"
	crown.position = base + Vector3(0, 4.8, 0)
	node.add_child(crown)
	var visual := MeshInstance3D.new()
	visual.name = "Mesh"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0
	mesh.bottom_radius = 2.6
	mesh.height = 7.0
	mesh.radial_segments = 7
	mesh.rings = 1
	mesh.material = material(Color("334e43") if index % 2 else Color("405c48"))
	visual.mesh = mesh
	crown.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.25
	shape.height = 5.5
	collision.shape = shape
	crown.add_child(collision)


func set_owners(node: Node) -> void:
	for child in node.get_children():
		if node is CharacterMotor and child.name in ["CollisionShape3D", "Visual"]:
			continue # Keep the shared character instance's ownership intact.
		child.owner = world
		set_owners(child)


func build() -> void:
	world = Node3D.new()
	world.name = "MapFoundation"
	# Reuse only M1's tested character/input/camera/interaction, not its world geometry.
	var old := load("res://scenes/prototype/m1_graybox.tscn").instantiate() as Node3D
	world.add_child(old.get_node("Environment").duplicate())
	world.add_child(old.get_node("Sun").duplicate())
	terrain()
	var roads := group(world, "Roads")
	for label in MapLayout.routes():
		road(roads, label, MapLayout.routes()[label])
	var station_geometry := group(world, "StationQuarter")
	shell(station_geometry, "Storehouse", Vector3(200, 0, 118), Vector2(14, 14))
	shell(station_geometry, "Workshop", Vector3(242, 0, 155), Vector2(16, 14))
	box(station_geometry, "BrokenWall", Vector3(234, 1.4, 120), Vector3(10, 2.8, 0.6), Color("9a988b"))
	box(station_geometry, "Crates", Vector3(196, 0.7, 153), Vector3(2, 1.4, 3), Color("71604a"))
	box(station_geometry, "YardStripeA", Vector3(220, 0.04, 128), Vector3(24, 0.03, 0.25), Color("b6ae84"), false)
	box(station_geometry, "YardStripeB", Vector3(220, 0.04, 152), Vector3(24, 0.03, 0.25), Color("b6ae84"), false)
	# A visible station silhouette, purely static: no fake call controls.
	box(station_geometry, "RadioMast", Vector3(230, 7, 126), Vector3(0.45, 14, 0.45), Color("536b6b"))
	box(station_geometry, "AntennaCrossbar", Vector3(230, 12, 126), Vector3(6, 0.25, 0.25), Color("b3ad89"))
	box(station_geometry, "RadioCabinet", Vector3(230, 0.8, 124), Vector3(1.4, 1.6, 1), Color("536b6b"))
	var tower := group(world, "Landmarks")
	for x in [-2.0, 2.0]:
		for z in [-2.0, 2.0]:
			box(tower, "TowerLeg" + str(x) + str(z), Vector3(95 + x, 6, 30 + z), Vector3(0.6, 12, 0.6), Color("615647"))
	box(tower, "WaterTank", Vector3(95, 13, 30), Vector3(7, 4, 7), Color("536b6b"))
	var ruins := group(world, "OldWorks")
	shell(ruins, "UnfinishedHall", Vector3(-110, 0, 20), Vector2(24, 20), 6)
	shell(ruins, "AbandonedOffice", Vector3(-65, 0, -15), Vector2(16, 14))
	box(ruins, "BrokenWall", Vector3(-55, 1.5, 50), Vector3(18, 3, 0.7), Color("9a988b"))
	var forest := group(world, "Forest")
	var tree_index := 0
	# Fixed groves, explicit gaps at routes. No per-frame generation or random scans.
	for center in [Vector2(285, 205), Vector2(330, 255), Vector2(120, -140), Vector2(170, -90)]:
		for row in range(4):
			for column in range(5):
				var p: Vector2 = center + Vector2(column * 7 + (row % 2) * 2, row * 8)
				var near_route := false
				for path in MapLayout.routes().values():
					for i in range(1, path.size()):
						var a := Vector2(path[i - 1].x, path[i - 1].z)
						var b := Vector2(path[i].x, path[i].z)
						if Geometry2D.get_closest_point_to_segment(p, a, b).distance_to(p) < 7:
							near_route = true
				if not near_route:
					tree(forest, tree_index, p.x, p.y)
					tree_index += 1
	# Forest edge in the representative AI area, away from starts and named sites.
	for i in range(8):
		tree(forest, tree_index + i, 252 + (i % 2) * 7, 104 + i * 7)
	var signs := group(world, "Signs")
	signpost(signs, "Welcome", 218, 159, "MAP LAYOUT / WASD + mouse\nSUMMIT: NW | STATION: N\nRescue not implemented")
	signpost(signs, "Station", 224, 134, "SIGNAL STATION\nFuture rescue yard\nNo call / extraction yet")
	signpost(signs, "Junction", 72, 50, "SUMMIT: NW / via north road\nOLD WORKS: W\nSTATION: SE")
	signpost(signs, "SouthTrail", -272, 8, "SUMMIT: N\nGentle walking approach")
	signpost(signs, "EastTrail", -43, -250, "SUMMIT: W\nNo jump required")
	signpost(signs, "Summit", -285, -270, "SUMMIT / BEACON SITE\nRescue not implemented")
	box(tower, "BeaconSurveyMast", MapLayout.point(-290, -260) + Vector3(0, 4, 0), Vector3(0.5, 8, 0.5), Color("b3ad89"))
	var markers := group(world, "AuthoringMarkers")
	for kind in ["Start", "Drop"]:
		var points := MapLayout.starts() if kind == "Start" else MapLayout.drops()
		for i in range(points.size()):
			var marker := Marker3D.new()
			marker.name = kind + str(i)
			marker.position = points[i]
			markers.add_child(marker)
	var local := group(world, "LocalArea")
	local.position = MapLayout.STATION
	local.set_script(load("res://scripts/ai/stage3c_local.gd"))
	var human := load("res://scenes/character/shared_character.tscn").instantiate() as CharacterMotor
	for component in ["CameraRig", "Interactor", "LocalController"]:
		human.add_child(old.get_node("Character/" + component).duplicate())
	human.name = "Character"
	human.position = Vector3(0, 0.1, 14)
	human.get_node("CameraRig/Pitch/SpringArm3D/Camera3D").far = 1400.0
	local.add_child(human)
	var lever := old.get_node("Lever").duplicate() as Node3D
	lever.position = Vector3(-4, 1, 18)
	local.add_child(lever)
	# Duplication must rebind exported node references to this composition.
	var interactor := human.get_node("Interactor") as CharacterInteractor
	interactor.target = lever as WorkTarget
	var input := human.get_node("LocalController")
	input.motor = human
	input.camera_rig = human.get_node("CameraRig")
	input.interactor = interactor
	signpost(signs, "Workbench", 212, 160, "E: M1 lever test only\nNot a rescue device")
	var destinations := group(local, "Destinations")
	var sites := [Vector3(-18, 0, 18), Vector3(-20, 0, -22), Vector3(-20, 0, -11), Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(22, 0, 15), Vector3(22, 0, 3), Vector3(32, 0, 32), Vector3(-32, 0, 32), Vector3(-32, 0, -32)]
	for i in range(sites.size()):
		var marker := Marker3D.new()
		marker.name = "Site" + str(i)
		marker.position = sites[i]
		marker.set_meta("area", StringName("quarter" + str(i % 3)))
		marker.set_meta("kind", &"observe" if i % 2 else &"transit")
		destinations.add_child(marker)
	var region := NavigationRegion3D.new()
	region.name = "NavigationRegion3D"
	region.position = -MapLayout.STATION
	if FileAccess.file_exists("res://scenes/world/station_navigation.tres"):
		region.navigation_mesh = load("res://scenes/world/station_navigation.tres")
	local.add_child(region)
	var overlay := CanvasLayer.new()
	overlay.name = "AIDebugOverlay"
	overlay.set_script(load("res://scripts/debug/ai_debug_overlay.gd"))
	local.add_child(overlay)
	old.free()
	set_owners(world)
	var packed := PackedScene.new()
	var result := packed.pack(world)
	if result == OK:
		result = ResourceSaver.save(packed, OUTPUT)
	print("Map authoring: ", result, "; trees ", tree_index + 8)
	world.free()
	quit(0 if result == OK else 1)
