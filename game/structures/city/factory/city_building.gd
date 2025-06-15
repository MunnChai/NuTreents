class_name CityBuilding
extends CityStructure

const NUM_CITY_SPRITES = 8

@export var cost_to_remove: int = 0

func _ready():
	super._ready()
	
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
	structure_type = Global.StructureType.CITY_BUILDING

## Returns the "height" that the arrow cursor should be above this structure...
## One of "low", "medium", and "high".
func get_arrow_cursor_height() -> String:
	if sprite_2d.texture.region.position.x == 32 * 3:
		return "medium"
	return "high"

func apply_data_resource(save_resource: Resource):
	structure_type = save_resource.type
	
	sprite_2d.flip_h = save_resource.flip_h
	
	sprite_2d.texture.region.position = save_resource.texture_region_position
