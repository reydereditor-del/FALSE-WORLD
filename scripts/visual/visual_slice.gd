extends Node3D
## Presentation-only composition for the separate showcase; old scenes are untouched.

const WORKER := preload("res://scripts/visual/worker_presentation.gd")
@export var place_player_at_entry: bool = true
var presentations: Array[WorkerPresentation] = []


func _ready() -> void:
	var area := get_parent().get_node("LocalArea")
	# Legacy capsule fixtures retain their instantaneous default; the playable rig
	# uses the same bounded visual turning already configured for the three AI.
	area.get_node("Character").facing_turn_speed = 3.5
	area.get_node("Character/LocalController").camera_facing_locomotion = true
	area.get_node("Character/CameraRig").minimum_pitch_degrees = -80.0
	if place_player_at_entry:
		area.get_node("Character").position = Vector3(-20, 0.1, -7)
	for actor: CharacterMotor in area.actors.values():
		var presentation := WorkerPresentation.new()
		presentation.name = "WorkerPresentation"
		actor.get_node("Visual").add_child(presentation)
		actor.get_node("Visual/Body").hide()
		actor.get_node("Visual/FacingMarker").hide()
		presentations.append(presentation)
	# The old hidden body remains the exact camera focus/reference; collider is unchanged.
