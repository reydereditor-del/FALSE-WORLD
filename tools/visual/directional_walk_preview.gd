extends Node3D
## Isolated editable-clip preview; never instantiates gameplay or AI.
const CLIPS := ["BackwardWalk", "StrafeLeft", "StrafeRight"]
const DIRECTIONS := [Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
var model: Node3D
var player: AnimationPlayer
var camera: Camera3D
var ground: Node3D
var label: Label
var selected := 0
var view_index := 2
var gameplay_speed := false
var elapsed := 0.0
var capture_path := ""
var capturing := false
var capture_fast := false

func _ready() -> void:
	model = preload("res://assets/visual/models/worker.glb").instantiate()
	model.scale = Vector3.ONE * 1.2
	model.rotation.y = PI
	add_child(model)
	for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		var material := mesh.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
		material.vertex_color_use_as_albedo = true
		material.roughness = .88
		mesh.material_override = material
	player = model.find_child("AnimationPlayer",true,false)
	var library := AnimationLibrary.new()
	for clip in CLIPS:
		library.add_animation(clip, load("res://assets/visual/animations/"+clip.to_snake_case()+".tres"))
	player.add_animation_library("Local",library)
	ground = Node3D.new(); add_child(ground)
	for x in range(-7,8):
		for z in range(-7,8):
			var mesh := MeshInstance3D.new()
			var box := BoxMesh.new(); box.size=Vector3(.495,.02,.495);mesh.mesh=box
			mesh.position=Vector3(x*.5,-.025,z*.5)
			var material := StandardMaterial3D.new()
			material.albedo_color=Color(.23,.25,.27) if (x+z)%2==0 else Color(.33,.35,.37)
			mesh.material_override=material;ground.add_child(mesh)
	var light := DirectionalLight3D.new();light.rotation_degrees=Vector3(-55,-35,0);light.light_energy=1.3;add_child(light)
	var env := WorldEnvironment.new();var environment := Environment.new()
	environment.background_mode=Environment.BG_COLOR;environment.background_color=Color(.16,.18,.21)
	environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color=Color(.8,.85,1);environment.ambient_light_energy=.65
	env.environment=environment;add_child(env)
	camera=Camera3D.new();add_child(camera);camera.current=true;camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=2.1
	var canvas := CanvasLayer.new();add_child(canvas);label=Label.new();label.position=Vector2(14,12);canvas.add_child(label)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):capture_path=argument.trim_prefix("--capture=")
		if argument == "--speed=4":capture_fast=true
	select()
	if not capture_path.is_empty(): call_deferred("capture")

func select() -> void:
	player.play("Local/"+CLIPS[selected],.15)
	elapsed=0
	var offsets := [Vector3(0,1.05,-3),Vector3(3,1.05,0),Vector3(2,1.4,-2)]
	camera.position=offsets[view_index];camera.look_at(Vector3(0,.75,0))

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():return
	if event.keycode >= KEY_1 and event.keycode <= KEY_3:selected=event.keycode-KEY_1;select()
	if event.keycode >= KEY_F1 and event.keycode <= KEY_F3:view_index=event.keycode-KEY_F1;select()
	if event.keycode==KEY_SPACE:gameplay_speed=not gameplay_speed;select()

func _process(delta: float) -> void:
	if capturing:return
	var clip := player.get_animation("Local/"+CLIPS[selected])
	var distance: float = clip.get_meta("distance_per_cycle")
	var speed := 4.0 if gameplay_speed else distance/clip.length
	player.speed_scale=speed/(distance/clip.length)
	elapsed+=delta
	ground.position=-DIRECTIONS[selected]*fposmod(elapsed*speed,.5)
	label.text="%s | %s | %.2f m/s\n1/2/3 clip | F1/F2/F3 front/side/three-quarter | Space authored/4 m/s" % [CLIPS[selected], ["front","side","three-quarter"][view_index], speed]

func capture() -> void:
	capturing=true
	DirAccess.make_dir_recursive_absolute(capture_path)
	get_window().size=Vector2i(640,640)
	for clip_index in range(3):
		selected=clip_index
		for view in (range(2,3) if capture_fast else range(3)):
			view_index=view;select();player.play("Local/"+CLIPS[selected], 0.0);player.advance(0);player.pause()
			# Three complete cycles at 24 samples per cycle, rendered with moving floor.
			var distance: float=player.get_animation("Local/"+CLIPS[selected]).get_meta("distance_per_cycle")
			for sample in range(181 if capture_fast else 73):
				var phase:=float(sample)/60.0*4.0/distance if capture_fast else float(sample)/24.0
				player.seek(fposmod(phase,1.0)*player.get_animation("Local/"+CLIPS[selected]).length,true)
				ground.position=-DIRECTIONS[selected]*fposmod(phase*distance,.5)
				label.text="%s | %s | %s | cycle %.2f" % [CLIPS[selected],["front","side","three-quarter"][view_index],"4 m/s" if capture_fast else "authored pace",phase]
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png(capture_path.path_join("%s-%d-%03d.png" % [CLIPS[selected],view,sample]))
	print("Preview capture complete; speed=",4 if capture_fast else "authored", "; output=",capture_path)
	get_tree().quit()
