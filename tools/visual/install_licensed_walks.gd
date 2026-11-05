extends SceneTree
## User-local installer. No controller scripts, meshes, actions or project settings imported.
## Both input archives stay on the user's machine. Output is excluded from Git.
const CONTROLLER_SHA := "945008784ba4f4f6ccd3bd4eee3bb6a8c70623e37c6697260831a442da2a771b"
const MOTIONS_SHA := "063d5e1822f85549d14035ef342b1feae45bac37962499a8b478c7eb997200cd"
const DEST := "res://assets/visual/licensed_locomotion"
const CACHE := "res://.godot/false_world_licensed_source"
func _initialize()->void:call_deferred("run")
func fail(message:String)->void:
	push_error(message);quit(2)
func find_entry(zip:ZIPReader,suffix:String)->String:
	var found:=""
	for entry in zip.get_files():
		if entry.ends_with(suffix):
			if not found.is_empty():return ""
			found=entry
	return found
func run()->void:
	var controller:="";var motions:=""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--controller-zip="):controller=argument.trim_prefix("--controller-zip=")
		if argument.begins_with("--motions-zip="):motions=argument.trim_prefix("--motions-zip=")
	if FileAccess.get_sha256(controller)!=CONTROLLER_SHA or FileAccess.get_sha256(motions)!=MOTIONS_SHA:
		fail("Pass the verified real-controller-1.3.0.zip and Human Basic Motions FREE 2.4 ZIP via --controller-zip= and --motions-zip=. No payment or Unity package needed.");return
	if DirAccess.dir_exists_absolute(DEST) and not FileAccess.file_exists(DEST.path_join("manifest.json")):
		fail("Destination exists without our generated manifest; preserving it. Choose a clean checkout or inspect that folder manually.");return
	var donor:=ZIPReader.new();var original:=ZIPReader.new()
	if donor.open(controller)!=OK or original.open(motions)!=OK:fail("Cannot read input ZIP archives");return
	DirAccess.make_dir_recursive_absolute(CACHE.path_join("animations"))
	for prefix in ["walk_","run_"]:
		for direction in ["forward","backward","left","right","forward_left","forward_right","backward_left","backward_right"]:
			var name:String=prefix+direction+".res"
			var entry:=find_entry(donor,"/animations/"+name)
			if entry.is_empty():fail("Missing/ambiguous animation: "+name);return
			var file:=FileAccess.open(CACHE.path_join("animations").path_join(name),FileAccess.WRITE)
			file.store_buffer(donor.read_file(entry));file.close()
	var scene:=find_entry(donor,"/real-controller/character.tscn")
	if scene.is_empty():fail("Source bone definitions not found");return
	var skeleton_data:=FileAccess.open(CACHE.path_join("character.tscn"),FileAccess.WRITE)
	skeleton_data.store_buffer(donor.read_file(scene));skeleton_data.close()
	var pdf:=find_entry(original,"Human Basic Motions 2.4 FREE.pdf")
	if pdf.is_empty():fail("Original author license/manual PDF missing");return
	var log:Array=[]
	var arguments:=PackedStringArray(["--headless","--path",ProjectSettings.globalize_path("res://"),"--script","res://tools/visual/retarget_uploaded_walks.gd","--","--licensed-import","--source-dir="+ProjectSettings.globalize_path(CACHE),"--output-dir="+ProjectSettings.globalize_path(DEST)])
	var code:=OS.execute(OS.get_executable_path(),arguments,log,true)
	for line in log:print(line)
	if code!=0 or not FileAccess.file_exists(DEST.path_join("manifest.json")):fail("Retargeting failed; inspect output above");return
	var notice:=FileAccess.open(DEST.path_join("Human Basic Motions 2.4 FREE.pdf"),FileAccess.WRITE)
	notice.store_buffer(original.read_file(pdf));notice.close()
	for name in ["RealController-MIT.txt","HumanBasicMotions-usage-notice.md"]:
		var legal:=FileAccess.open(DEST.path_join(name),FileAccess.WRITE)
		legal.store_string(FileAccess.get_file_as_string("res://assets/licenses/"+name));legal.close()
	var metadata:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(DEST.path_join("manifest.json")))
	metadata["controller_sha256"]=CONTROLLER_SHA;metadata["motions_sha256"]=MOTIONS_SHA
	var manifest:=FileAccess.open(DEST.path_join("manifest.json"),FileAccess.WRITE)
	manifest.store_string(JSON.stringify(metadata,"  "));manifest.close()
	donor.close();original.close()
	print("Installed 16 locally licensed worker clips. F5 Stage 4 now uses directional locomotion. These assets are excluded from Git; keep the original archives and notices.")
	quit()
