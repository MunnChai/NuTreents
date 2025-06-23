class_name SoundEmitterComponent
extends Node2D

@export var sound_effect_name: String

func play_sound_effect(sfx_name: String = sound_effect_name) -> void:
	SfxManager.play_sound_effect(sfx_name)
