extends Control
## Bounded actual-body moving-floor experiment. Production scripts remain unchanged.
const PROFILES := [Vector2(1.75,2.25),Vector2(1.10,.85),Vector2(.90,.65)]
const NAMES := ["Starting ranges", "Middle", "Lower cadence"]
const DURATION := 17.0
const STAGES := ["Forward", "Forward -> left strafe", "Strafe -> forward", "Forward -> backward", "Backward -> back-right diagonal", "Stop", "Forward-right diagonal", "Right strafe", "Camera yaw +90", "Stop"]
var actors:Array[CharacterMotor]=[]
var cameras:Array[Camera3D]=[]
var labels:Array[Label]=[]
var skins:Array[WorkerPresentation]=[]
var elapsed:=0.0
var output:=""
var frame_index:=0
var trace:Array[Dictionary]=[]
var finished:=false
@export var auto_finish:=true

func _ready() -> void:
	process_physics_priority=-20
	get_window().size=Vector2i(1440,640)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):output=argument.trim_prefix("--capture=")
	if not output.is_empty():DirAccess.make_dir_recursive_absolute(output)
	var row:=HBoxContainer.new();row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);row.add_theme_constant_override("separation",0);add_child(row)
	for index in range(3):
		var container:=SubViewportContainer.new();container.size_flags_horizontal=Control.SIZE_EXPAND_FILL;container.stretch=true;row.add_child(container)
		var viewport:=SubViewport.new();viewport.size=Vector2i(480,640);viewport.world_3d=World3D.new();container.add_child(viewport)
		var world:=Node3D.new();viewport.add_child(world)
		var actor:=load("res://scenes/character/shared_character.tscn").instantiate() as CharacterMotor
		actor.set_script(load("res://tools/visual/experimental_walk_motor.gd"))
		actor.backward_speed=PROFILES[index].x;actor.lateral_speed=PROFILES[index].y;actor.facing_turn_speed=3.5
		actor.position=Vector3(0,.01,0)
		actor.get_node("Visual/Body").visible=false;actor.get_node("Visual/FacingMarker").visible=false
		var presentation:=WorkerPresentation.new();presentation.set_script(load("res://tools/visual/experimental_walk_presentation.gd"))
		actor.get_node("Visual").add_child(presentation);world.add_child(actor)
		actors.append(actor);skins.append(presentation)
		print("Profile ",index," physics space ",actor.get_world_3d().space)
		var floor:=StaticBody3D.new();var shape:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(200,.1,200);shape.shape=box;shape.position.y=-.05;floor.add_child(shape);world.add_child(floor)
		var mesh:=MeshInstance3D.new();var plane:=PlaneMesh.new();plane.size=Vector2(200,200);mesh.mesh=plane;floor.add_child(mesh)
		var shader:=Shader.new();shader.code="shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){vec2 p=wp.xz;vec2 c=abs(fract(p)-0.5);float line=step(0.48,max(c.x,c.y));float checker=mod(floor(p.x)+floor(p.y),2.0);ALBEDO=mix(mix(vec3(0.24),vec3(0.34),checker),vec3(0.65,0.58,0.30),line);ROUGHNESS=1.0;}"
		var material:=ShaderMaterial.new();material.shader=shader;mesh.material_override=material
		for z in range(-20,12,2):
			var mark:=Label3D.new();mark.text="%d m"%z;mark.position=Vector3(1.2,.01,z);mark.rotation_degrees.x=-90;mark.font_size=48;mark.pixel_size=.006;world.add_child(mark)
		var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-55,-30,0);light.light_energy=1.4;world.add_child(light)
		var env:=WorldEnvironment.new();var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color(.12,.15,.19);e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color(.8,.85,1);e.ambient_light_energy=.7;env.environment=e;world.add_child(env)
		var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=3.0;world.add_child(camera);cameras.append(camera);camera.current=true
		var canvas:=CanvasLayer.new();viewport.add_child(canvas);var label:=Label.new();label.position=Vector2(8,8);label.add_theme_font_size_override("font_size",15);canvas.add_child(label);labels.append(label)
	RenderingServer.frame_post_draw.connect(capture)

func stage(t:float)->int:
	if t<1.5:return 0
	if t<3.5:return 1
	if t<4.5:return 2
	if t<6.5:return 3
	if t<8.5:return 4
	if t<9.5:return 5
	if t<11.5:return 6
	if t<13.5:return 7
	if t<16:return 8
	return 9

func _physics_process(delta:float)->void:
	if finished:return
	elapsed+=delta
	var current:=stage(elapsed)
	var directions:=[Vector3.FORWARD,Vector3.LEFT,Vector3.FORWARD,Vector3.BACK,Vector3(1,0,1).normalized(),Vector3.ZERO,Vector3(1,0,-1).normalized(),Vector3.RIGHT,Vector3.RIGHT,Vector3.ZERO]
	for index in range(3):
		var yaw:=0.0 if current<8 else minf((elapsed-13.5)/1.0,1.0)*PI/2
		actors[index].facing_yaw=yaw
		actors[index].set_facing_intent(Basis(Vector3.UP,yaw)*Vector3.FORWARD)
		actors[index].set_move_intent(Basis(Vector3.UP,yaw)*directions[current])
	if elapsed>=DURATION:finished=true

func _process(_delta:float)->void:
	if actors.is_empty():return
	for index in range(3):
		var actor:=actors[index]
		cameras[index].position=actor.position+Vector3(2.5,1.9,-3.8)
		cameras[index].look_at(actor.position+Vector3(0,.75,0))
		labels[index].text="%s\nForward 4.00 | Back %.2f | Side %.2f m/s\n%s\nActual %.2f m/s | world (%.2f, %.2f)\nGround: 1 m grid; fixed in world\n%.2f s"%[NAMES[index],PROFILES[index].x,PROFILES[index].y,STAGES[stage(elapsed)],Vector2(actor.velocity.x,actor.velocity.z).length(),actor.position.x,actor.position.z,elapsed]
	if finished and auto_finish:
		if not output.is_empty():
			var f:=FileAccess.open(output.path_join("trace.json"),FileAccess.WRITE);f.store_string(JSON.stringify(trace,"  "))
		print("Moving walk experiment complete; actual physics; profiles=",PROFILES," frames=",frame_index)
		get_tree().quit()

func capture()->void:
	if actors.is_empty():return
	if not output.is_empty():
		get_viewport().get_texture().get_image().save_png(output.path_join("%04d.png"%frame_index))
		var poses:Array=[]
		for i in range(3):poses.append({"position":actors[i].position,"speed":Vector2(actors[i].velocity.x,actors[i].velocity.z).length(),"phase":skins[i].phase,"weights":skins[i].blend_weights,"player_active":skins[i].animation_player.is_playing(),"yaw":actors[i].get_node("Visual").rotation.y,"left_ankle":skins[i].skeleton.global_transform*skins[i].skeleton.get_bone_global_pose(13).origin,"right_ankle":skins[i].skeleton.global_transform*skins[i].skeleton.get_bone_global_pose(17).origin})
		trace.append({"frame":frame_index,"t":elapsed,"stage":STAGES[stage(elapsed)],"actors":poses})
	frame_index+=1
