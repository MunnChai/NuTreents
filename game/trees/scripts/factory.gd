class_name Factory
extends Structure

@onready var sprite_2d = $Sprite2D

@export var cost_to_remove: int = 0

func _ready():
	var rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
	id = "factory"
