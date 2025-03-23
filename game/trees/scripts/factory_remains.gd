class_name FactoryRemains
extends Structure

@onready var sprite_2d = $Sprite2D

var tech_slot: int = -1

func _ready():
	var rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
	id = "factory_remains"
