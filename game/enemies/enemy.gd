class_name Enemy
extends Node

const ATTACK_SPEED: int = 1 # per second

@export_group("Enemy Stats")
@export var health: int
@export var attack_damage: int
@export var move_speed: int

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

# Tree that it is targeting
var currently_targeting: Node2D 

# 
func find_nearest_tree() -> void:
	pass
