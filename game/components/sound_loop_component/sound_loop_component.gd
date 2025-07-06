class_name SoundLoopComponent
extends Node

## Loops sound until it dies

@export var grid_position: GridPositionComponent
@export var sound_id: StringName

var audio: AudioStreamPlayer2D

func start() -> void:
	if not grid_position:
		grid_position = Components.get_component(get_owner(), GridPositionComponent)
	
	audio = SoundManager.start_player(sound_id, Global.terrain_map.map_to_local(grid_position.get_pos()))

func end() -> void:
	if audio:
		audio.stop()
		audio.queue_free()

func _exit_tree() -> void:
	end()
