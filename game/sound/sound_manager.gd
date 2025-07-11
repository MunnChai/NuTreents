class_name SoundManagerGlobal
extends Node

## NEW AND IMPROVED VERSION OF SFX MANAGER

const LOG_LOADING := true

## TODO:
## - Limit amount of times per second same track can be played
## - Pool audio players?
## - Vary strength of on-screen sound players by zoom scale

var dict: Dictionary[StringName, SoundResource] = {}

func _ready() -> void:
	for sound: SoundResource in DataUtil.load_all_resources_in_folder("res://sound/sound_resources/", "SoundResource"):
		dict.set(sound.id, sound)

func get_sound(id: StringName) -> SoundResource:
	if not dict.has(id):
		print("WARNING! Attempting to play sound \"{id}\", but it is not registered. Did you make a typo?".format({ "id": id }))
	return dict.get(id)

func play_oneshot(id: StringName, global_pos: Vector2) -> void:
	var audio_player := start_player(id, global_pos)
	
	if audio_player:
		await audio_player.finished
	
		audio_player.queue_free()

func play_global_oneshot(id: StringName) -> void:
	var audio_player := start_global_player(id)
	
	if audio_player:
		await audio_player.finished
	
		audio_player.queue_free()

const DEFAULT_ATTENUATION := 8.0

const SOUND_PLAYER = preload("./sound_player.tscn")
func start_player(id: StringName, global_pos: Vector2) -> AudioStreamPlayer2D:
	var sound := get_sound(id)
	if not sound:
		return null
	
	var stream := sound.get_random_audio_stream()
	
	var audio_player = SOUND_PLAYER.instantiate()
	add_child(audio_player)
	audio_player.base_attenuation = DEFAULT_ATTENUATION
	if sound.attenuation_override >= 0.0:
		audio_player.base_attenuation = sound.attenuation_override
	audio_player.global_position = global_pos
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-sound.pitch_variation_range, sound.pitch_variation_range)
	audio_player.base_volume = sound.linear_volume
	audio_player.bus = "SFX"
	audio_player.update_attributes()
	audio_player.play()
	
	return audio_player

func start_global_player(id: StringName, linear_volume: float = 0.7) -> AudioStreamPlayer:
	var sound := get_sound(id)
	if not sound:
		return null
	
	var stream := sound.get_random_audio_stream()
	
	var audio_player = AudioStreamPlayer.new()
	audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(audio_player)
	audio_player.stream = stream
	audio_player.pitch_scale = 1.0 + randf_range(-sound.pitch_variation_range, sound.pitch_variation_range)
	audio_player.volume_linear = linear_volume
	audio_player.bus = "SFX"
	audio_player.play()
	
	return audio_player
