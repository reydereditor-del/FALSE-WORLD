extends SceneTree
## Actual game rendering, not replacement game assets. Run with a real/virtual display.

var output := "/tmp/false-world-visual"


func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			output = argument.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(output)
	call_deferred("run")


func settle(count: int) -> void:
	for i in range(count):
		await process_frame


func capture(name: String) -> void:
	await settle(4)
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(output.path_join(name + ".png"))
	if error != OK:
		push_error("Preview image failed: " + name)


func run() -> void:
	root.size = Vector2i(1280, 720)
	for entry in ["before", "after"]:
		var path := "res://scenes/world/map_foundation.tscn" if entry == "before" else "res://scenes/visual/visual_vertical_slice.tscn"
		var world := load(path).instantiate() as Node3D
		root.add_child(world)
		var area := world.get_node("LocalArea")
		area.get_node("Character/LocalController").set_physics_process(false)
		area.get_node("Character").global_position = Vector3(200, 0.1, 133)
		area.set_physics_process(false)
		for controller in area.controllers:
			controller.set_physics_process(false)
			controller.motor.set_move_intent(Vector3.ZERO)
		await settle(10)
		await capture(entry + "-player")
		var camera := Camera3D.new()
		camera.far = 1400
		camera.position = Vector3(212, 4, 138)
		world.add_child(camera)
		camera.look_at(Vector3(199, 1.6, 119))
		camera.current = true
		await capture(entry + "-entry")
		camera.position = Vector3(201, 2.2, 122)
		camera.look_at(Vector3(194, 1.4, 116))
		await capture(entry + "-interior")
		world.queue_free()
		await settle(4)
	print("Actual previews saved to ", output)
	quit()
