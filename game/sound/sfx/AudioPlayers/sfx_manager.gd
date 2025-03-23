extends Node

var tree_plant: AudioStreamPlayer
const TREE_PLANT = preload("res://sound/sfx/AudioPlayers/tree_plant.tscn")
var gun_tree_projectile: AudioStreamPlayer
const GUN_TREE_PROJECTILE = preload("res://sound/sfx/AudioPlayers/gun_tree_projectile.tscn")
var tree_damage: AudioStreamPlayer
const TREE_DAMAGE = preload("res://sound/sfx/AudioPlayers/tree_damage.tscn")
var speedle_die: AudioStreamPlayer
const SPEEDLE_DIE = preload("res://sound/sfx/AudioPlayers/speedle_die.tscn")
var tree_remove: AudioStreamPlayer
const TREE_REMOVE = preload("res://sound/sfx/AudioPlayers/tree_remove.tscn")

var SFX_DICT: Dictionary[String, AudioStreamPlayer]  

func _ready() -> void:
	#tree_plant sfx
	tree_plant = TREE_PLANT.instantiate()
	add_child(tree_plant)
	SFX_DICT["tree_plant"] = tree_plant
	
	#gun_tree_projectile sfx
	gun_tree_projectile = GUN_TREE_PROJECTILE.instantiate()
	add_child(gun_tree_projectile)
	SFX_DICT["gun_tree_projectile"] = gun_tree_projectile
	
	#tree_damage sfx
	tree_damage = TREE_DAMAGE.instantiate()
	add_child(tree_damage)
	SFX_DICT["tree_damage"] = tree_damage
	
	#speedle_die sfx
	speedle_die = SPEEDLE_DIE.instantiate()
	add_child(speedle_die)
	SFX_DICT["speedle_die"] = speedle_die
	
	#tree_remove sfx
	tree_remove = TREE_REMOVE.instantiate()
	add_child(tree_remove)
	SFX_DICT["tree_remove"] = tree_remove
	

func play_sound_effect(name: String) -> void:
	var sound_effect: AudioStreamPlayer = SFX_DICT[name]
	if (sound_effect != null): 
		sound_effect.playing = true
