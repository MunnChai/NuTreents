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
	TILE_TYPE.WATER: Vector2i(0, 12), # TEMP
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
	
	# Create rivers
	generate_rivers()
	
	# Generate random cities
	generate_cities()
	
	# Create spawn area of grass
	generate_spawn()
	
	# Randomize tiles based on biome
	randomize_tiles()




func initialize_map() -> void:
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

func generate_rivers() -> void:
	
	# Create noise
	var river_noise := FastNoiseLite.new()
	river_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	river_noise.seed = randi()
	river_noise.frequency = 0.015
	river_noise.fractal_octaves = 4
	river_noise.fractal_lacunarity = 2
	river_noise.fractal_gain = 0.5
	
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
			
			var tile_type: int = TILE_TYPE.GRASS
			if (scaled_value > 0.5 && scaled_value < 0.8):
				tile_type = TILE_TYPE.WATER
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
			
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			
			tile_data.set_custom_data("biome", tile_type)

func generate_cities() -> void:
	var num_cities: int = randi_range(MIN_CITIES, MAX_CITIES)
	
	var angle: float = randf() * 2 * PI
	for i in range(0, num_cities):
		
		var map_coords: Vector2i =  Constants.MAP_SIZE / 2
		
		map_coords += Vector2i(Vector2.RIGHT.rotated(angle) * CITY_DISTANCE)
		
		generate_city(map_coords)
		
		angle += 2 * PI / num_cities

func generate_city(map_coords: Vector2i) -> void:
	for i in range(0, NUM_DRUNKARDS):
		walk_drunkard(map_coords, TILE_TYPE.CITY)

func generate_spawn() -> void:
	var origin: Vector2i = Vector2i(Constants.MAP_SIZE / 2)
	
	for i in range(0, NUM_DRUNKARDS * 4):
		walk_drunkard(origin, TILE_TYPE.GRASS)





func walk_drunkard(map_coords: Vector2i, tile_type: TILE_TYPE):
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
			continue
		if (current_coord.x < 0 || current_coord.y < 0):
			continue
		
		# Set to City Tile
		var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
		set_cell(current_coord, SOURCE_ID, atlas_coords, 0)
		var tile_data: TileData = get_cell_tile_data(current_coord)
		tile_data.set_custom_data("biome", tile_type)
		
		drunkard_life -= 1




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
