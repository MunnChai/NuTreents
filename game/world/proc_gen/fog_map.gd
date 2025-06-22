class_name FogMap
extends TileMapLayer

const DEFAULT_VISION_RANGE = 3
const FOG_SIZE = Global.MAP_SIZE * 4

var tree_vision_range: int = DEFAULT_VISION_RANGE

@onready var solid_atlas_coords := get_solid_atlas_coords()
@onready var semi_transparent_atlas_coords := get_semi_transparent_atlas_coords()
@onready var transparent_atlas_coords := get_transparent_atlas_coords()

func init() -> void:
	for x in range(Global.ORIGIN.x - FOG_SIZE.x / 2, Global.ORIGIN.x + FOG_SIZE.x / 2): # Munn: Ignore how ugly this is lol
		for y in range(Global.ORIGIN.y - FOG_SIZE.y / 2, Global.ORIGIN.y + FOG_SIZE.y / 2):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Vector2i(Global.MAP_SIZE) / 2
			
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (Global.MAP_SIZE.length())
			
			var atlas_coords: Vector2i = get_random_solid_atlas_coords()
			
			set_cell(map_coords, 0, atlas_coords, 0)

func remove_fog_around(map_coords: Vector2i):
	for x in range(map_coords.x - tree_vision_range, map_coords.x + tree_vision_range):
		for y in range(map_coords.y - tree_vision_range, map_coords.y + tree_vision_range):
			## ATTEMPT AT CIRCULAR
			#var dist = map_coords.distance_to(Vector2i(x, y))
			#if dist >= tree_vision_range:
				#continue
			
			var current_coord: Vector2i = Vector2i(x, y)
			
			erase_cell(current_coord)
			
			var base_surrounding = get_surrounding_cells(current_coord)
			
			for cell in base_surrounding:
				for another_cell in get_surrounding_cells(cell):
					if get_cell_atlas_coords(another_cell) in transparent_atlas_coords:
						continue
					if get_cell_tile_data(another_cell) != null:
						set_cell(another_cell, 0, get_random_most_transparent_atlas_coords(), 0)
			
			for cell in base_surrounding:
				if get_cell_tile_data(cell) != null:
					set_cell(cell, 0, get_random_transparent_atlas_coords(), 0)

func update_surrounding_tiles(map_coords: Vector2i):
	var is_tree_here: bool = TreeManager.get_tree_map().has(map_coords)

func is_tile_foggy(map_coord) -> bool: 
	if get_cell_tile_data(map_coord) == null:
		return false
	
	var atlas_coords = get_cell_atlas_coords(map_coord)
	if atlas_coords in semi_transparent_atlas_coords or atlas_coords in transparent_atlas_coords:
		return false
	
	return true

func get_solid_atlas_coords() -> Array[Vector2i]:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var array: Array[Vector2i] = []
	for i in range(0, 8):
		for j in range(0, 2):
			var true_index = i * 4 + j
			array.append(fog_source.get_tile_id(true_index))
	
	return array

func get_semi_transparent_atlas_coords() -> Array[Vector2i]:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var array: Array[Vector2i] = []
	for i in range(0, 8):
		for j in range(2, 3):
			var true_index = i * 4 + j
			array.append(fog_source.get_tile_id(true_index))
	
	return array

func get_transparent_atlas_coords() -> Array[Vector2i]:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var array: Array[Vector2i] = []
	for i in range(0, 8):
		for j in range(3, 4):
			var true_index = i * 4 + j
			array.append(fog_source.get_tile_id(true_index))
	
	return array

# Munn: get_random_solid/transparent_atlas_coords both have HARD CODED THINGS, so if you change the fog tilesheet, CHANGE THE HARD CODED PARTS TOO (i have marked them)
func get_random_solid_atlas_coords() -> Vector2i:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var rand_index = randi_range(0, 7) # Munn: HARD CODED range(0, NUM_HORIZONTAL_TILES)
	
	var true_index = (rand_index * 4) + randi_range(0, 1)

	return fog_source.get_tile_id(true_index)

func get_random_transparent_atlas_coords() -> Vector2i:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var rand_index = randi_range(0, 7) # Munn: HARD CODED range(0, NUM_HORIZONTAL_TILES)
	
	var true_index = (rand_index * 4) + 3 # Munn: HARD CODED (rand_index * NUM_VERTICAL_TILES) + (NUM_VERTICAL_TILES - 1)
	
	return fog_source.get_tile_id(true_index)

func get_random_most_transparent_atlas_coords() -> Vector2i:
	var fog_source: TileSetSource = tile_set.get_source(0)
	
	var rand_index = randi_range(0, 7) # Munn: HARD CODED range(0, NUM_HORIZONTAL_TILES)
	
	var true_index = (rand_index * 4) + 2 # Munn: HARD CODED (rand_index * NUM_VERTICAL_TILES) + (NUM_VERTICAL_TILES - 1)
	
	return fog_source.get_tile_id(true_index)
