extends Node

var tree_plant: AudioStreamPlayer
const TREE_PLANT = preload("res://sound/sfx/AudioPlayers/tree_plant.tscn")

var SFX_DICT: Dictionary[String, AudioStreamPlayer]  

func _ready() -> void:
	tree_plant = TREE_PLANT.instantiate()
	add_child(tree_plant)
	SFX_DICT["tree_plant"] = tree_plant

func play_sound_effect(name: String) -> void:
	var sound_effect: AudioStreamPlayer = SFX_DICT[name]
	if (sound_effect != null): 
		sound_effect.playing = true
	tree_plant.play()
