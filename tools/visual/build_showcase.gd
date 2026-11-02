extends SceneTree
## Offline bounded art authoring. Materials/props are real resources, never screenshots.

var art: Node3D
var concrete: StandardMaterial3D
var steel: StandardMaterial3D
var gravel: StandardMaterial3D
var dark: StandardMaterial3D
var leaf: StandardMaterial3D


func _initialize() -> void:
	call_deferred("build")


func pbr(name: String, tiling: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	var prefix := "res://assets/visual/materials/" + name + "/"
	mat.albedo_texture = load(prefix + "albedo.jpg")
	mat.normal_enabled = true
	mat.normal_texture = load(prefix + "normal.png")
	mat.normal_scale = 0.4 if name == "concrete" else 0.5
	mat.roughness_texture = load(prefix + "roughness.png")
	mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	mat.roughness = 1.0
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3.ONE * tiling
	if name == "steel":
		mat.metallic = 1.0
		mat.metallic_texture = load(prefix + "metallic.png")
		mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	ResourceSaver.save(mat, "res://assets/visual/materials/" + name + ".tres")
	return mat


func simple(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.92
	return mat


func mesh_node(label: String, mesh: Mesh, position_value: Vector3, parent: Node = null) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.position = position_value
	(art if parent == null else parent).add_child(node)
	return node


func box(label: String, position_value: Vector3, size: Vector3, mat: Material, solid: bool = false) -> Node3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	if not solid:
		return mesh_node(label, mesh, position_value)
	var body := StaticBody3D.new()
	body.name = label
	body.position = position_value
	art.add_child(body)
	mesh_node("Mesh", mesh, Vector3.ZERO, body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body


func cylinder(label: String, position_value: Vector3, radius: float, height_value: float, mat: Material, axis: Vector3 = Vector3.UP) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height_value
	mesh.radial_segments = 16
	mesh.rings = 1
	mesh.material = mat
	var node := mesh_node(label, mesh, position_value)
	if axis != Vector3.UP:
		node.quaternion = Quaternion(Vector3.UP, axis)
	return node


func imported_prop(name: String, position_value: Vector3, scale_value: float, rotation_value: float) -> void:
	var model := load("res://assets/visual/models/" + name + ".glb").instantiate() as Node3D
	model.name = name
	model.position = position_value
	model.scale = Vector3.ONE * scale_value
	model.rotation.y = rotation_value
	art.add_child(model)


func foliage() -> void:
	# Original bent, tapered leaf ribbons. MultiMesh: two draw instances, no grass nodes.
	for variant in range(2):
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		for blade in range(7):
			var angle := blade * TAU / 7.0
			var direction := Vector3(cos(angle), 0, sin(angle))
			var side := Vector3(-direction.z, 0, direction.x) * 0.045
			var base := direction * 0.06
			var mid := direction * 0.14 + Vector3.UP * (0.30 + variant * 0.05)
			var tip := direction * 0.33 + Vector3.UP * (0.38 + variant * 0.08)
			for point in [base - side, mid - side * 0.6, base + side, base + side, mid - side * 0.6, mid + side * 0.6, mid - side * 0.6, tip, mid + side * 0.6]:
				surface.add_vertex(point)
		surface.generate_normals()
		var mesh := surface.commit()
		var mat := simple(Color("4b5140") if variant else Color("636751"))
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh.surface_set_material(0, mat)
		var transforms: Array[Transform3D] = []
		var rng := RandomNumberGenerator.new()
		rng.seed = 724 + variant
		for i in range(180):
			var x := rng.randf_range(185, 215)
			var z := rng.randf_range(110, 141)
			# Keep centre entry lane, doors/interior, and tested west corner walk clear.
			if (x > 192 and x < 208 and z < 126) or absf(x - 200) < 3 or (x > 189 and x < 211 and z > 127 and z < 131):
				continue
			transforms.append(Transform3D(Basis(Vector3.UP, rng.randf_range(0, TAU)).scaled(Vector3.ONE * rng.randf_range(0.65, 1.25)), Vector3(x, 0.02, z)))
		var multi := MultiMesh.new()
		multi.transform_format = MultiMesh.TRANSFORM_3D
		multi.mesh = mesh
		multi.instance_count = transforms.size()
		for i in range(transforms.size()):
			multi.set_instance_transform(i, transforms[i])
		var node := MultiMeshInstance3D.new()
		node.name = "GroundWeeds" + str(variant)
		node.multimesh = multi
		art.add_child(node)
		for i in range(3):
			var clump := mesh_node("WallWeeds" + str(variant) + str(i), mesh,
				Vector3(207.8 + variant * 0.5, 0.02, 122.5 + i * 1.5))
			clump.scale = Vector3.ONE * 2.0


func set_owners(node: Node) -> void:
	if node != art and not node.scene_file_path.is_empty():
		return
	for child in node.get_children():
		child.owner = art
		set_owners(child)


func build() -> void:
	concrete = pbr("concrete", 0.5)
	steel = pbr("steel", 0.75)
	gravel = pbr("gravel", 0.3)
	dark = simple(Color("202923"))
	leaf = simple(Color("4f5544"))
	art = Node3D.new()
	art.name = "StationArt"
	art.set_script(load("res://scripts/visual/visual_slice.gd"))
	var ground_mat := ShaderMaterial.new()
	ground_mat.shader = load("res://scripts/visual/ground_blend.gdshader")
	ground_mat.set_shader_parameter("albedo_map", gravel.albedo_texture)
	ground_mat.set_shader_parameter("normal_map", gravel.normal_texture)
	ground_mat.set_shader_parameter("roughness_map", gravel.roughness_texture)
	box("GravelApron", Vector3(200, 0.012, 126), Vector3(32, 0.012, 32), ground_mat)
	box("InteriorFloor", Vector3(200, 0.023, 118), Vector3(13.4, 0.012, 13.4), concrete)
	box("EntryWalk", Vector3(200, 0.025, 133), Vector3(4, 0.012, 14), concrete)
	# Frames overlay existing solid wall/lintel volumes, leaving both 4 m doors intact.
	for z in [110.65, 125.35]:
		for x in [197.88, 202.12]:
			box("DoorJamb" + str(x) + str(z), Vector3(x, 1.9, z), Vector3(0.18, 3.8, 0.18), steel)
		box("DoorHeader" + str(z), Vector3(200, 3.9, z), Vector3(4.5, 0.22, 0.25), steel)
	# Corrugated roof strip follows the existing partial roof; no new low ceiling.
	for i in range(28):
		cylinder("Corrugation" + str(i), Vector3(195, 4.66, 111.25 + i * 0.49), 0.10, 4.0, steel, Vector3.RIGHT)
	for z in [111.4, 117.8, 124.6]:
		box("RoofBeam" + str(z), Vector3(195, 4.7, z), Vector3(4.5, 0.13, 0.15), steel)
	# Exposed conduits, straps, vents and corrosion on real wall surfaces.
	cylinder("ConduitVertical", Vector3(207.36, 2.1, 120), 0.11, 4.0, steel)
	cylinder("ConduitHorizontal", Vector3(207.36, 3.6, 117), 0.11, 6.0, steel, Vector3.BACK)
	for z in [114, 117, 120]:
		box("PipeStrap" + str(z), Vector3(207.42, 3.6, z), Vector3(0.12, 0.32, 0.16), dark)
	box("VentBack", Vector3(207.34, 2.6, 114), Vector3(0.12, 1.4, 1.7), steel)
	for i in range(9):
		box("VentSlat" + str(i), Vector3(207.43, 2.0 + i * 0.145, 114), Vector3(0.11, 0.05, 1.5), dark)
	for x in [193.5, 196, 204, 206.5]:
		box("FoundationBand" + str(x), Vector3(x, 0.25, 125.34), Vector3(1.3, 0.5, 0.10), concrete)
	var faded_paint := concrete.duplicate() as StandardMaterial3D
	faded_paint.albedo_color = Color(0.62, 0.69, 0.62)
	for x in [195.5, 204.5]:
		box("FadedPaint" + str(x), Vector3(x, 1.2, 125.311), Vector3(5.0, 0.55, 0.012), faded_paint)
	box("RelayPlaque", Vector3(204.6, 2.6, 125.38), Vector3(1.9, 0.75, 0.06), steel)
	var text_label := Label3D.new()
	text_label.name = "FacilityStencil"
	text_label.text = "RELAY / 03\nSERVICE BUILDING"
	text_label.font_size = 32
	text_label.pixel_size = 0.003
	text_label.modulate = Color("b4b2a0")
	text_label.position = Vector3(204.6, 2.6, 125.417)
	art.add_child(text_label)
	# Proper supported clutter table. Its collider is included in a separate local bake.
	box("Workbench", Vector3(194.3, 0.48, 117), Vector3(1.1, 0.96, 3.2), steel, true)
	box("WorkbenchTop", Vector3(194.3, 0.99, 117), Vector3(1.3, 0.08, 3.4), concrete)
	imported_prop("BoomBox", Vector3(194.3, 1.275, 117), 25, PI / 2)
	# Lantern source is a full hanging post assembly, not a little tabletop lantern.
	imported_prop("Lantern", Vector3(211, -0.018, 119), 0.115, PI / 2)
	var post := StaticBody3D.new()
	post.name = "LanternPostCollider"
	post.position = Vector3(211, 1.5, 117.75)
	var post_collision := CollisionShape3D.new()
	var post_shape := CylinderShape3D.new()
	post_shape.radius = 0.16
	post_shape.height = 3.0
	post_collision.shape = post_shape
	post.add_child(post_collision)
	art.add_child(post)
	# Rusted barrel stacks away from the clear entrance, with independent simple colliders.
	for i in range(3):
		var position_value := Vector3(212.5 + (i % 2) * 1.05, 0.62, 133.5 + (i / 2) * 1.1)
		cylinder("Drum" + str(i), position_value, 0.43, 1.24, steel)
		for h in [-0.49, 0.0, 0.49]:
			cylinder("DrumRim" + str(i) + str(h), position_value + Vector3.UP * h, 0.45, 0.045, dark)
		var body := StaticBody3D.new()
		body.name = "DrumCollider" + str(i)
		body.position = position_value
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 0.44
		shape.height = 1.24
		collision.shape = shape
		body.add_child(collision)
		art.add_child(body)
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	for i in range(32):
		var x := rng.randf_range(185, 215)
		var z := rng.randf_range(126, 141)
		if absf(x - 200) < 3 or (z > 127 and z < 131):
			continue
		var shard := PrismMesh.new()
		shard.size = Vector3(rng.randf_range(0.12, 0.35), rng.randf_range(0.03, 0.08), rng.randf_range(0.18, 0.45))
		shard.material = concrete
		var node := mesh_node("ConcreteShard" + str(i), shard, Vector3(x, 0.03, z))
		node.rotation.y = rng.randf_range(0, TAU)
	foliage()
	var light := OmniLight3D.new()
	light.name = "WorkbenchWarmBounce"
	light.position = Vector3(195.2, 2.4, 118)
	light.light_color = Color("e4c99b")
	light.light_energy = 0.6
	light.omni_range = 4.0
	light.shadow_enabled = false
	art.add_child(light)
	set_owners(art)
	var packed := PackedScene.new()
	var error := packed.pack(art)
	if error == OK:
		error = ResourceSaver.save(packed, "res://scenes/visual/station_art.tscn")
	if error != OK:
		push_error("Showcase art save failed")
		quit(1)
		return
	# Sky-based overcast atmosphere. Restrained distance fog, no volumetrics/SSAO/SSR.
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("747c82")
	sky_material.sky_horizon_color = Color("939a9f")
	sky_material.ground_bottom_color = Color("404a43")
	sky_material.ground_horizon_color = Color("939a9f")
	sky_material.sky_energy_multiplier = 0.4
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.4
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color("8c968e")
	env.fog_light_energy = 0.7
	env.fog_density = 0.002
	env.fog_sun_scatter = 0.05
	ResourceSaver.save(env, "res://assets/visual/overcast.tres")
	var base := load("res://scenes/world/map_foundation.tscn").instantiate() as Node3D
	var text := "[gd_scene load_steps=7 format=3]\n\n"
	text += '[ext_resource type="PackedScene" path="res://scenes/world/map_foundation.tscn" id="1_base"]\n'
	text += '[ext_resource type="PackedScene" path="res://scenes/visual/station_art.tscn" id="2_art"]\n'
	text += '[ext_resource type="Material" path="res://assets/visual/materials/concrete.tres" id="3_concrete"]\n'
	text += '[ext_resource type="Material" path="res://assets/visual/materials/steel.tres" id="4_steel"]\n'
	text += '[ext_resource type="Environment" path="res://assets/visual/overcast.tres" id="5_environment"]\n'
	text += '[ext_resource type="NavigationMesh" path="res://scenes/visual/station_visual_navigation.tres" id="6_nav"]\n\n'
	text += '[node name="VisualVerticalSlice" instance=ExtResource("1_base")]\n\n'
	text += '[node name="Environment" parent="."]\nenvironment = ExtResource("5_environment")\n\n'
	text += '[node name="Sun" parent="."]\nrotation_degrees = Vector3(-48, -35, 0)\nlight_color = Color(0.86, 0.90, 0.92, 1)\nlight_energy = 0.65\nlight_angular_distance = 8.0\nshadow_enabled = true\ndirectional_shadow_max_distance = 65.0\n\n'
	for body in base.get_node("StationQuarter/Storehouse").get_children():
		var path := 'StationQuarter/Storehouse/' + String(body.name)
		var id := "4_steel" if String(body.name).begins_with("Lintel") or body.name == &"BrokenRoof" else "3_concrete"
		text += '[node name="Mesh" parent="' + path + '"]\nmaterial_override = ExtResource("' + id + '")\n\n'
	text += '[node name="NavigationRegion3D" parent="LocalArea"]\nnavigation_mesh = ExtResource("6_nav")\n\n'
	text += '[node name="StationArt" parent="." instance=ExtResource("2_art")]\n'
	var file := FileAccess.open("res://scenes/visual/visual_vertical_slice.tscn", FileAccess.WRITE)
	file.store_string(text)
	file.close()
	base.free()
	art.free()
	print("Showcase art and scene saved")
	quit()
