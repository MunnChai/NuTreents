extends Node

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

var clock: Clock

func _ready() -> void:
	clock = get_tree().root.find_child("Clock", true, false)
	audio_stream_player.play()


enum Vibe {
	SMALL_FOREST,
	MEDIUM_FOREST,
	LARGE_FOREST,
	CALM_NIGHT,
	MILD_NIGHT,
	INTENSE_NIGHT,
	SILENCE
}

var current_vibe = Vibe.CALM_NIGHT

func _process(delta: float) -> void:
	if audio_stream_player.get_stream_playback() == null:
		return
	
	if len(get_tree().get_nodes_in_group("enemies")) > 15:
		if current_vibe != Vibe.INTENSE_NIGHT:
			audio_stream_player.get_stream_playback().switch_to_clip_by_name("intense")
			current_vibe = Vibe.INTENSE_NIGHT
		# audio_stream_player["parameters/switch_to_clip"] = "intense"
	elif len(get_tree().get_nodes_in_group("enemies")) > 3:
		if current_vibe != Vibe.MILD_NIGHT:
			audio_stream_player.get_stream_playback().switch_to_clip_by_name("mild")
			current_vibe = Vibe.MILD_NIGHT
			# audio_stream_player["parameters/switch_to_clip"] = "mild"
	else:
		if current_vibe != Vibe.CALM_NIGHT:
			audio_stream_player.get_stream_playback().switch_to_clip_by_name("calm")
			current_vibe = Vibe.CALM_NIGHT
