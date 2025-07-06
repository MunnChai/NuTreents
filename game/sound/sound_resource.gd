class_name SoundResource
extends Resource

## A resource representing a sound with an id

@export var id: StringName
@export var linear_volume: float = 1.0
@export var pitch_variation_range: float = 0.3
@export var audio_streams: Array[AudioStream]

func get_audio_stream(index: int = 0) -> AudioStream:
	index = clampi(index, 0, audio_streams.size() - 1)
	
	return audio_streams[index]

func get_random_audio_stream() -> AudioStream:
	return audio_streams.pick_random()
