class_name TerrainMap
extends TileMapLayer

enum TILE_TYPE {
	GRASS = 0,
	DIRT = GRASS + 1,
	CITY = DIRT + 1,
	WATER = CITY + 1,
}

const TILE_ATLAS_COORDS: Dictionary[TILE_TYPE, Vector2i] = {
	TILE_TYPE.GRASS: Vector2i(0, 0),
	TILE_TYPE.DIRT: Vector2i(0, 2),
	TILE_TYPE.CITY: Vector2i(0, 4),
	TILE_TYPE.WATER: Vector2i(0, 14),
}

const TILE_TYPE_VARIATIONS: Dictionary[TILE_TYPE, int] = {
	TILE_TYPE.GRASS: 4,
	TILE_TYPE.DIRT: 4,
	TILE_TYPE.CITY: 4,
	TILE_TYPE.WATER: 1,
}

const SOURCE_ID: int = 0
const BIOME_FALLOFF = 2

const MIN_CITIES: int = 3
const MAX_CITIES: int = 5
const CITY_DISTANCE: int = Constants.MAP_SIZE.x / 2.5
const DRUNKARD_LIFETIME: int = 15
const NUM_DRUNKARDS: int = 10

const TARGETED_DRUNKARD_LIFETIME: int = 60
const TARGETED_NUM_DRUNKARDS: int = 1
const TARGETED_DRUNKARD_INTELLIGENCE: float = 0.85

@onready var test_image: TextureRect = $CanvasLayer/TextureRect

func _ready() -> void:
	generate_map()
	
	y_sort_enabled = true

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	
	if (event is InputEventKey && event.is_action_pressed("generate_map")):
		generate_map()


func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_local_mouse_position()
	
	return mouse_screen_pos


func generate_map() -> void:
	print("Generating map...")
	
	
	
	# Fill map with grass
	initialize_map()
	
	# Create rivers, and get river tiles for later
	var river_tiles: Array[Vector2i] = get_rivers()
	
	# Generate random cities
	var city_coords: Array[Vector2i]
	var num_cities: int = randi_range(MIN_CITIES, MAX_CITIES)
	
	var angle: float = randf() * 2 * PI
	for i in range(0, num_cities):
		
		var map_coords: Vector2i =  Constants.MAP_SIZE / 2
		map_coords += Vector2i(Vector2.RIGHT.rotated(angle) * CITY_DISTANCE)
		city_coords.append(map_coords)
		
		angle += 2 * PI / num_cities
	
	# Generate roads between cities first
	generate_roads(city_coords)
	
	# Generate cities on top of roads (pretty important, otherwise roads will "cut through" cities)
	generate_cities(city_coords)
	
	# Create spawn area of grass
	generate_spawn()
	
	# Randomize tiles based on biome
	randomize_tiles()
	
	# Generate rivers at the end of map generation, so autotiling works
	generate_rivers(river_tiles)




func initialize_map() -> void:
	
	var grass_tiles: Array[Vector2i]
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Vector2i(Constants.MAP_SIZE) / 2
			
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (Constants.MAP_SIZE.length() * BIOME_FALLOFF)
			
			var tile_type: int = TILE_TYPE.GRASS
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			tile_data.set_custom_data("biome", tile_type)
			
			grass_tiles.append(map_coords)
	
	#set_cells_terrain_connect(grass_tiles, 0, 0)

func get_rivers() -> Array[Vector2i]:
	
	# Create noise
	var river_noise := FastNoiseLite.new()
	river_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	river_noise.seed = randi()
	river_noise.frequency = 0.015
	river_noise.fractal_octaves = 4
	river_noise.fractal_lacunarity = 2
	river_noise.fractal_gain = 0.5
	
	var river_tiles: Array[Vector2i]
	
	# For each tile
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Vector2i(Constants.MAP_SIZE) / 2
			
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (Constants.MAP_SIZE.length() * BIOME_FALLOFF)
			
			# Some value between 0.0 and 1.0
			var noise = river_noise.get_noise_2dv(map_coords)
			var noise_clamped: float = clamp((noise + distance_scaled) , 0, 0.99)
			var scaled_value: float = noise_clamped * TILE_ATLAS_COORDS.size()
			
			if (scaled_value > 0.5 && scaled_value < 0.8):
				var tile_type: int = TILE_TYPE.WATER
			
				var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
				
				set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
				
				var tile_data: TileData = get_cell_tile_data(map_coords)
				
				tile_data.set_custom_data("biome", tile_type)
				
				river_tiles.append(map_coords)
	
	# Call deferred so that terrain connections are made after all generation is finished
	#call_deferred("set_cells_terrain_connect", river_tiles, 0, 1)
	return river_tiles

# Called at the end of map generation
# Removes non-water tiles from river_tiles, and then sets the cells to connect
func generate_rivers(river_tiles: Array[Vector2i]) -> void:
	var to_remove: Array[Vector2i] = []
	for map_coords in river_tiles:
		
		# remove from array if: tile data is null, or tile already has an assigned biome that isn't river
		var tile_data: TileData = get_cell_tile_data(map_coords)
		if (tile_data == null):
			to_remove.append(map_coords)
			continue
		
		var tile_type: int = tile_data.get_custom_data("biome")
		if (tile_type == null || tile_type != TILE_TYPE.WATER):
			to_remove.append(map_coords)
	
	for map_coords in to_remove:
		river_tiles.erase(map_coords)
	
	set_cells_terrain_connect(river_tiles, 0, 1)
	
	for map_coords in river_tiles:
		var tile_data: TileData = get_cell_tile_data(map_coords)
		tile_data.set_custom_data("biome", TILE_TYPE.WATER)


func generate_cities(city_coords: Array[Vector2i]):
	for map_coords in city_coords:
		generate_city(map_coords)


func generate_roads(city_coords: Array[Vector2i]) -> void:
	
	for i in range(0, city_coords.size()):
		if (i == city_coords.size() - 1):
			return
		
		var curr_city: Vector2 = city_coords[i]
		var next_city: Vector2 = city_coords[i + 1]
		
		build_road(curr_city, next_city)

func build_road(city_i: Vector2i, city_j: Vector2i) -> void:
	
	for i in range(0, TARGETED_NUM_DRUNKARDS):
		walk_drunkard_targeted(city_i, city_j, TILE_TYPE.DIRT)


func generate_city(map_coords: Vector2i) -> void:
	for i in range(0, NUM_DRUNKARDS):
		walk_drunkard(map_coords, TILE_TYPE.CITY)

func generate_spawn() -> void:
	var origin: Vector2i = Vector2i(Constants.MAP_SIZE / 2)
	
	for i in range(0, NUM_DRUNKARDS * 4):
		walk_drunkard(origin, TILE_TYPE.GRASS, [TILE_TYPE.DIRT])





func walk_drunkard(map_coords: Vector2i, tile_type: TILE_TYPE, irreplaceable_tiles: Array[TILE_TYPE] = []):
	var drunkard_life: int = DRUNKARD_LIFETIME
	var current_coord: Vector2i = map_coords
	while (drunkard_life > 0):
		# Walk in a random direction
		var rand: int = randi_range(0, 3)
		
		var direction: Vector2i
		match (rand):
			0:
				direction = Vector2i.UP
			1:
				direction = Vector2i.DOWN
			2:
				direction = Vector2i.LEFT
			3:
				direction = Vector2i.RIGHT
		
		current_coord += direction
		
		if (current_coord.x >= Constants.MAP_SIZE.x || current_coord.y >= Constants.MAP_SIZE.y):
			drunkard_life -= 1
			continue
		if (current_coord.x < 0 || current_coord.y < 0):
			drunkard_life -= 1
			continue
		
		var tile_data: TileData = get_cell_tile_data(current_coord)
		
		if (tile_data != null):
			var current_tile: TILE_TYPE = tile_data.get_custom_data("biome")
			
			if (irreplaceable_tiles.find(current_tile) > -1):
				drunkard_life -= 1
				continue
		
		
		# Set to City Tile
		var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
		set_cell(current_coord, SOURCE_ID, atlas_coords, 0)
		tile_data = get_cell_tile_data(current_coord)
		tile_data.set_custom_data("biome", tile_type)
		
		drunkard_life -= 1



func walk_drunkard_targeted(start_coords: Vector2i, target_coords: Vector2i, tile_type: TILE_TYPE) -> bool:
	var drunkard_life: int = TARGETED_DRUNKARD_LIFETIME
	var current_coord: Vector2i = start_coords
	while (drunkard_life > 0):
		if (current_coord == target_coords):
			return true
		
		# Find the "best" direction towards the target
		var target_direction: Vector2 = Vector2(target_coords - current_coord).normalized()
		
		var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
		# Sort 4 directions by "goodness" to the target
		directions.sort_custom(
			func(a: Vector2i, b: Vector2i):
				
				var target_diff_a: float = (Vector2(a) - target_direction).length()
				var target_diff_b: float = (Vector2(b) - target_direction).length()
				
				return target_diff_a < target_diff_b
		)
		
		# Iterate through directions, every iteration, there is a 75% chance the direction will be chosen
		var direction: Vector2i
		for i in range(0, directions.size() - 1):
			direction = directions[i]
			
			var rand: float = randf()
			if (rand < TARGETED_DRUNKARD_INTELLIGENCE):
				break
		
		# Move in direction
		current_coord += direction
		
		if (current_coord.x >= Constants.MAP_SIZE.x || current_coord.y >= Constants.MAP_SIZE.y):
			drunkard_life -= 1
			continue
		if (current_coord.x < 0 || current_coord.y < 0):
			drunkard_life -= 1
			continue
		
		# Set to City Tile
		var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
		set_cell(current_coord, SOURCE_ID, atlas_coords, 0)
		var tile_data: TileData = get_cell_tile_data(current_coord)
		tile_data.set_custom_data("biome", tile_type)
		
		drunkard_life -= 1
	
	return false



func randomize_tiles() -> void:
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			var biome: int = tile_data.get_custom_data("biome")
			var scaled_value: float = randf() * (TILE_TYPE_VARIATIONS[biome] - 1)
			var modifier: int = floor(scaled_value)
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[biome] + Vector2i(modifier, 0)
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
