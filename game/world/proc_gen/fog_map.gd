class_name FogMap
extends TileMapLayer

const FOG_SIZE = Constants.MAP_SIZE * 2

var tree_vision_range: int = 2


func _ready() -> void:
	init()

func init() -> void:
	for x in range(-Constants.MAP_SIZE.x / 2, FOG_SIZE.x - Constants.MAP_SIZE.x / 2): # Munn: Ignore how ugly this is lol
		for y in range(-Constants.MAP_SIZE.y / 2, FOG_SIZE.y - Constants.MAP_SIZE.y / 2):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Vector2i(Constants.MAP_SIZE) / 2
			
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (Constants.MAP_SIZE.length())
			
			var atlas_coords: Vector2i = get_random_solid_atlas_coords()
			
			set_cell(map_coords, 0, atlas_coords, 0)

func remove_fog_around(map_coords: Vector2i):
	for x in range(map_coords.x - tree_vision_range, map_coords.x + tree_vision_range):
		for y in range(map_coords.y - tree_vision_range, map_coords.y + tree_vision_range):
			var current_coord: Vector2i = Vector2i(x, y)
			
			erase_cell(current_coord)

func update_surrounding_tiles(map_coords: Vector2i):
	var is_tree_here: bool = TreeManager.tree_map.has(map_coords)
	
	





# Munn: get_random_solid/transparent_atlas_coords both have HARD CODED THINGS, so if you change the fog tilesheet, CHANGE THE HARD CODED PARTS TOO (i have marked them)
func get_random_solid_atlas_coords() -> Vector2i:
	var fog_source: TileSetSource = tile_set.get_source(0)
	var num_tiles: int = fog_source.get_tiles_count()
	var random_index: int = int(randf() * num_tiles)
	
	if ((random_index + 1) % 4 == 0): # Munn: HARD CODED (random_index + 1) % NUM_VERTICAL_TILES
		random_index -= 1
	
	return fog_source.get_tile_id(random_index)

func get_random_transparent_atlas_coords() -> Vector2i:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var rand_index = randi_range(0, 7) # Munn: HARD CODED range(0, NUM_HORIZONTAL_TILES)
	
	var true_index = (rand_index * 4) + 3 # Munn: HARD CODED (rand_index * NUM_VERTICAL_TILES) + (NUM_VERTICAL_TILES - 1)
	
	return fog_source.get_tile_id(true_index)
