extends SceneTree
## Offline retarget of user-licensed Human Basic Motions data.
## Import through install_licensed_walks.gd; never publish generated asset files.
## Reads source bone transforms as data; never instantiates the supplied controller.
## godot --headless --path . --script res://tools/visual/retarget_uploaded_walks.gd --
##   --source-dir=<.../addons/real-controller> --output-dir=<outside project>
var source_directory := ""
var output_directory := ""
var licensed_import := false
const ALIGN := Basis(Vector3.UP, PI)
var source: Skeleton3D
var target: Skeleton3D
var model: Node3D
var frame: Transform3D
var source_rest: Array[Transform3D]=[]
var target_rest: Array[Transform3D]=[]
var leg_scale:=1.0
var max_error:=0.0
var source_clip:Animation
var source_tracks:Array[int]=[]
var ankle_floor:Array[float]=[]
const SOURCE_NAMES := ["Hips","Spine","Chest","Neck","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","LeftToes","RightUpperLeg","RightLowerLeg","RightFoot","RightToes"]
var source_ids:Array[int]=[]

func _initialize()->void:call_deferred("run")
func target_point(bone:int)->Vector3:return frame*target.get_bone_global_pose(bone).origin
func source_point(bone:int)->Vector3:return ALIGN*source.get_bone_global_pose(source_ids[bone]).origin
func source_rest_point(bone:int)->Vector3:return ALIGN*source_rest[source_ids[bone]].origin
func orient(bone:int,basis:Basis)->void:
	var p:=target.get_bone_parent(bone)
	var parent_basis:=frame.basis if p<0 else (frame*target.get_bone_global_pose(p)).basis
	target.set_bone_pose_rotation(bone,(parent_basis.inverse()*basis).orthonormalized().get_rotation_quaternion())
func aim(bone:int,child:int,direction:Vector3)->void:
	var from:=(target_point(child)-target_point(bone)).normalized()
	var to:=direction.normalized()
	orient(bone,Basis(Quaternion(from,to))*(frame*target.get_bone_global_pose(bone)).basis)
func source_delta(bone:int)->Basis:
	var id:=source_ids[bone]
	return ALIGN*source.get_bone_global_pose(id).basis.orthonormalized()*source_rest[id].basis.inverse()*ALIGN.inverse()
func apply_source(time:float)->void:
	for i in range(source.get_bone_count()):source.reset_bone_pose(i)
	for track in range(source_clip.get_track_count()):
		var id:=source_tracks[track]
		if id<0:continue
		match source_clip.track_get_type(track):
			Animation.TYPE_POSITION_3D:source.set_bone_pose_position(id,source_clip.position_track_interpolate(track,time))
			Animation.TYPE_ROTATION_3D:source.set_bone_pose_rotation(id,source_clip.rotation_track_interpolate(track,time))
			Animation.TYPE_SCALE_3D:source.set_bone_pose_scale(id,source_clip.scale_track_interpolate(track,time))
func solve_leg(hip:int,knee:int,ankle:int,toe:int,side:int)->void:
	var wanted:=target_rest[ankle].origin+(source_point(ankle)-source_rest_point(ankle))*leg_scale
	wanted.y=target_rest[ankle].origin.y+(source_point(ankle).y-ankle_floor[side])*leg_scale
	var origin:=target_point(hip)
	var upper:=origin.distance_to(target_point(knee));var lower:=target_point(knee).distance_to(target_point(ankle))
	var line:=wanted-origin;var axis:=line.normalized()
	var distance:=clampf(line.length(),.01,upper+lower-.001)
	var source_axis:=(source_point(ankle)-source_point(hip)).normalized()
	var pole:=source_point(knee)-source_point(hip)
	pole=(pole-source_axis*pole.dot(source_axis)).normalized()
	if pole.length_squared()<.1:pole=Vector3.FORWARD
	var bend:=(pole-axis*pole.dot(axis)).normalized()
	var along:=(upper*upper-lower*lower+distance*distance)/(2*distance)
	var height:=sqrt(maxf(upper*upper-along*along,0))
	aim(hip,knee,origin+axis*along+bend*height-origin)
	aim(knee,ankle,wanted-target_point(knee))
	orient(ankle,source_delta(ankle)*target_rest[ankle].basis)
	orient(toe,source_delta(toe)*target_rest[toe].basis)
	max_error=maxf(max_error,target_point(ankle).distance_to(wanted))
func pose(time:float)->void:
	apply_source(time)
	for i in range(19):target.reset_bone_pose(i)
	var pelvis:=target_rest[0].origin+(source_point(0)-source_rest_point(0))*leg_scale
	target.set_bone_pose_position(0,frame.affine_inverse()*pelvis)
	for i in range(5):orient(i,source_delta(i)*target_rest[i].basis)
	for chain in [[5,6,7],[8,9,10]]:
		var a:int=chain[0];var b:int=chain[1];var c:int=chain[2]
		orient(a,source_delta(a)*target_rest[a].basis)
		aim(a,b,source_point(b)-source_point(a))
		orient(b,source_delta(b)*target_rest[b].basis)
		aim(b,c,source_point(c)-source_point(b))
		var from:=(target_rest[c].origin-target_rest[b].origin).normalized()
		var to:=(target_point(c)-target_point(b)).normalized()
		orient(c,Basis(Quaternion(from,to))*target_rest[c].basis)
	for chain in [[11,12,13,14,0],[15,16,17,18,1]]:solve_leg(chain[0],chain[1],chain[2],chain[3],chain[4])
func bake(name:String)->bool:
	source_clip=load(source_directory.path_join("animations").path_join(name+".res"))
	source_tracks.clear()
	for t in range(source_clip.get_track_count()):
		var path:=source_clip.track_get_path(t)
		source_tracks.append(source.find_bone(path.get_subname(0)) if path.get_subname_count()>0 else -1)
	ankle_floor=[INF,INF]
	var samples:=int(round(source_clip.length*60))
	for j in range(samples+1):
		apply_source(source_clip.length*float(j)/samples)
		for side in range(2):ankle_floor[side]=minf(ankle_floor[side],source_point(13 if side==0 else 17).y)
	var animation:=Animation.new();animation.length=source_clip.length;animation.loop_mode=Animation.LOOP_LINEAR;animation.resource_name=name
	animation.set_meta("source_package","user supplied real-controller-1.3.0.zip")
	animation.set_meta("license","Standard Asset Store EULA; Kevin Iglesias; local user-licensed data")
	animation.set_meta("nominal_speed",(4.0 if name.begins_with("run_") else 2.0)*leg_scale)
	for i in range(19):
		for type in [Animation.TYPE_POSITION_3D,Animation.TYPE_ROTATION_3D]:
			var track:=animation.add_track(type);animation.track_set_path(track,NodePath("Z_UP/Armature/Skeleton3D:"+String(target.get_bone_name(i))))
	max_error=0.0
	for j in range(samples+1):
		var time:=animation.length*float(j)/samples
		pose(time if j<samples else 0.0)
		for i in range(19):
			animation.position_track_insert_key(i*2,time,target.get_bone_pose_position(i))
			animation.rotation_track_insert_key(i*2+1,time,target.get_bone_pose_rotation(i))
	if ResourceSaver.save(animation,output_directory.path_join(name+".tres"))!=OK:
		push_error("Cannot write retargeted animation: "+name);quit(2);return false
	print(name," length=",animation.length," source ankle minima=",ankle_floor," max IK error=",max_error)
	return true
func run()->void:
	for argument in OS.get_cmdline_user_args():
		if argument=="--licensed-import":licensed_import=true
		if argument.begins_with("--source-dir="):source_directory=argument.trim_prefix("--source-dir=")
		if argument.begins_with("--output-dir="):output_directory=argument.trim_prefix("--output-dir=")
	if source_directory.is_empty() or output_directory.is_empty():
		push_error("Pass --source-dir=<extracted addon folder> --output-dir=<folder outside project>")
		quit(2);return
	output_directory=ProjectSettings.globalize_path(output_directory).simplify_path()
	var project_root:=ProjectSettings.globalize_path("res://").simplify_path()
	if output_directory.begins_with(project_root.trim_suffix("/")) and not (licensed_import and output_directory==project_root.path_join("assets/visual/licensed_locomotion").simplify_path()):
		push_error("Use the licensed installer for the ignored local asset directory")
		quit(2);return
	source=Skeleton3D.new();root.add_child(source)
	var bones:Array=[]
	var text:=FileAccess.get_file_as_string(source_directory.path_join("character.tscn"))
	var pattern:=RegEx.new()
	for i in range(56):
		pattern.compile('(?m)^bones/%d/name = "([^\"]+)"'%i)
		var name_match:=pattern.search(text)
		assert(name_match!=null,"Expected original 56-bone Real Controller 1.3.0 source scene")
		pattern.compile('(?m)^bones/%d/parent = (-?[0-9]+)'%i)
		var parent_match:=pattern.search(text)
		pattern.compile('(?m)^bones/%d/rest = Transform3D\\(([^)]+)\\)'%i)
		var rest_match:=pattern.search(text)
		assert(parent_match!=null and rest_match!=null)
		var values:Array=[]
		for value in rest_match.get_string(1).split(","):values.append(value.to_float())
		assert(values.size()==12)
		bones.append({"name":name_match.get_string(1),"parent":parent_match.get_string(1).to_int(),"rest":values})
	for bone in bones:
		source.add_bone(bone.name)
	for i in range(bones.size()):
		var a:Array=bones[i].rest
		source.set_bone_parent(i,int(bones[i].parent))
		source.set_bone_rest(i,Transform3D(Basis(Vector3(a[0],a[1],a[2]),Vector3(a[3],a[4],a[5]),Vector3(a[6],a[7],a[8])),Vector3(a[9],a[10],a[11])))
		source.reset_bone_pose(i)
	for i in range(source.get_bone_count()):source_rest.append(source.get_bone_global_pose(i))
	for name in SOURCE_NAMES:source_ids.append(source.find_bone(name))
	model=load("res://assets/visual/models/worker.glb").instantiate();model.scale=Vector3.ONE*1.2;model.rotation.y=PI;root.add_child(model)
	(model.find_child("AnimationPlayer",true,false) as AnimationPlayer).stop()
	target=model.find_child("Skeleton3D",true,false);frame=target.global_transform
	for i in range(19):target.reset_bone_pose(i)
	for i in range(19):target_rest.append(frame*target.get_bone_global_pose(i))
	leg_scale=(target_rest[11].origin.distance_to(target_rest[12].origin)+target_rest[12].origin.distance_to(target_rest[13].origin))/(source_rest_point(11).distance_to(source_rest_point(12))+source_rest_point(12).distance_to(source_rest_point(13)))
	print("Source bones=",source.get_bone_count()," target=",target.get_bone_count()," leg scale=",leg_scale)
	DirAccess.make_dir_recursive_absolute(output_directory)
	var clip_names:Array[String]=[]
	for prefix in ["walk_","run_"]:
		for direction in ["forward","backward","left","right","forward_left","forward_right","backward_left","backward_right"]:
			clip_names.append(prefix+direction)
	for name in clip_names:
		if not bake(name):return
	var manifest:={"format":1,"clips":clip_names,"walk_nominal_speed":2.0*leg_scale,"run_nominal_speed":4.0*leg_scale,"license":"Standard Asset Store EULA; Kevin Iglesias; local install only","source":"real-controller-1.3.0 normalized Human Basic Motions FREE 2.4"}
	var file:=FileAccess.open(output_directory.path_join("manifest.json"),FileAccess.WRITE)
	if file==null:push_error("Cannot write animation manifest");quit(2);return
	file.store_string(JSON.stringify(manifest,"  "));file.close()
	model.queue_free();source.queue_free();await process_frame;quit()
