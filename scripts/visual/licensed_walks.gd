class_name LicensedWalks
extends RefCounted
## Data access only. User-installed EULA assets are excluded from the public checkout.
const DIRECTORY := "res://assets/visual/licensed_locomotion"
const DIRECTIONS := ["forward","forward_right","right","backward_right","backward","backward_left","left","forward_left"]
static func installed()->bool:
	if not FileAccess.file_exists(DIRECTORY.path_join("manifest.json")):return false
	for prefix in ["walk_","run_"]:
		for direction in DIRECTIONS:
			if not FileAccess.file_exists(DIRECTORY.path_join(prefix+direction+".tres")):return false
	return true
static func add_library(player:AnimationPlayer)->bool:
	if not installed():return false
	var library:=AnimationLibrary.new()
	for prefix in ["walk_","run_"]:
		for direction in DIRECTIONS:
			var name:String=prefix+direction
			var clip:=load(DIRECTORY.path_join(name+".tres")) as Animation
			if clip==null:return false
			library.add_animation(name,clip)
	player.add_animation_library("Licensed",library)
	return true
static func select_clip(local_velocity:Vector3)->StringName:
	var sector:=posmod(int(round(atan2(local_velocity.x,-local_velocity.z)/(PI/4))),8)
	var prefix:="run_" if Vector2(local_velocity.x,local_velocity.z).length()>2.6 else "walk_"
	return StringName(prefix+DIRECTIONS[sector])
