extends Structure
class_name City

const NUM_CITY_SPRITES = 6
const TILE_SIZE: Vector2 = Vector2(32, 16)

@onready var sprite_2d = $Sprite2D

var type: int # 1: Skyscraper; 2: general city tile; 3: Factory
var sprite_id: int = 0

func _init(t: int, p: Vector2):
	super._init(p)
	type = t
	
	sprite_id = randi_range(0, NUM_CITY_SPRITES - 1)
	sprite_2d.texture.region.x + sprite_id * TILE_SIZE.x

func breakdown() -> Ground:
	var fac = (type == 3)
	var ground = Ground.new(1, fac, pos)
	return ground
