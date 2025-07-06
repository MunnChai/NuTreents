class_name SoundManagerGlobal
extends Node

## NEW AND IMPROVED VERSION OF SFX MANAGER

## TODO:
## - Limit amount of times per second same track can be played
## - Pool audio players?

var dict: Dictionary[StringName, SoundResource] = {}

func _ready() -> void:
	for sound: SoundResource in load_all_resource_in_folder("res://sound/sound_resources/", "SoundResource"):
		dict.set(sound.id, sound)

## Recursively loads all of resource_type in path and returns the list
func load_all_resource_in_folder(path: String, resource_type: String) -> Array[Resource]:
	var result: Array[Resource] = []
	
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		
		if dir.current_is_dir():
			result.append_array(load_all_resource_in_folder(file_path, resource_type))
		else:
			var resource: Resource = ResourceLoader.load(file_path, resource_type)
			if resource:
				result.append(resource)
		
		file_name = dir.get_next()
	
	return result

func get_sound(id: StringName) -> SoundResource:
	return dict.get(id)

func play_oneshot(id: StringName, global_pos: Vector2) -> void:
	var sound := get_sound(id)
	if not sound:
		return
	
	var stream := sound.get_random_audio_stream()
	
	var audio_player = AudioStreamPlayer2D.new()
	add_child(audio_player)
	audio_player.global_position = global_pos
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-sound.pitch_variation_range, sound.pitch_variation_range)
	audio_player.play()
	
	await audio_player.finished
	
	audio_player.queue_free()
