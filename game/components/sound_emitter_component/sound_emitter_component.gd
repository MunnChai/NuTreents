class_name SoundEmitterComponent
extends Node2D

@export var sound_effect_name: String

func play_sound_effect(sfx_name: String = sound_effect_name) -> void:
	SoundManager.play_oneshot(sfx_name, global_position)
