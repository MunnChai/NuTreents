class_name CityBuilding
extends Structure

const NUM_CITY_SPRITES = 8
@onready var sprite_2d = $Sprite2D

func _ready():
	sprite_2d.texture = sprite_2d.texture.duplicate()
	var texture: AtlasTexture = sprite_2d.texture
	
	var rand = randi_range(0, NUM_CITY_SPRITES - 1)
	var v_pos = 0
	if (rand > 3):
		rand = rand % 4
		v_pos = 1
	
	texture.region.position.x = rand * 32
	texture.region.position.y = 16 + v_pos * 64
	
	rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
	id = "city_building"
