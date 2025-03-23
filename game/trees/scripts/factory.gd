class_name Factory
extends Structure

@onready var sprite_2d = $Sprite2D

func _ready():
	var rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
	id = "factory"
