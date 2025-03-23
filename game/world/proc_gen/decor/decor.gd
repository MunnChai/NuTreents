class_name Decor
extends Structure

@onready var sprite_2d = $Sprite2D

@export var num_tiles: int
@export var decor_id: String = "decor"

func _ready():
	# Duplicate texture (so the same texture isn't used for every decor object)
	sprite_2d.texture = sprite_2d.texture.duplicate()
	var texture: AtlasTexture = sprite_2d.texture
	
	# Get a random "frame"
	var rand = randi_range(0, num_tiles - 1)
	
	# Set texture region
	texture.region.position.x = rand * 32
	
	# Flip randomly
	rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
	# If we want to have separate info box stuff
	id = decor_id
