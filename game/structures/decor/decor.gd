class_name Decor
extends Structure

@onready var sprite_2d = $Sprite2D

@export var num_tiles: int
@export var decor_id: String = "decor"
@export var tile_type: TerrainMap.TileType

var structure_type := Global.StructureType.DECOR

const TILE_TYPE_Y_OFFSETS = {
	TerrainMap.TileType.GRASS: 32,
	TerrainMap.TileType.DIRT: 32 + 64,
	TerrainMap.TileType.CITY: 32 + 64 + 64,
}

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

func apply_data_resource(save_resource: Resource):
	sprite_2d.flip_h = save_resource.flip_h
	sprite_2d.texture.region.position = save_resource.texture_region_position
	set_decor_type(save_resource.tile_type)

func set_decor_type(type: TerrainMap.TileType):
	tile_type = type
	sprite_2d.texture.region.position.y = TILE_TYPE_Y_OFFSETS[tile_type]
