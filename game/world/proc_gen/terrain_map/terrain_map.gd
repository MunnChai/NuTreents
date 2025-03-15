class_name TerrainMap
extends TileMapLayer

@onready var test_image: TextureRect = $CanvasLayer/TextureRect

const SOURCE_ID: int = 0
const BIOME_FALLOFF = 4

enum TILE_TYPE {
	GRASS = 0,
	DIRT = GRASS + 1,
	CITY = DIRT + 1,
}

const TILE_ATLAS_COORDS: Dictionary[TILE_TYPE, Vector2i] = {
	TILE_TYPE.GRASS: Vector2i(0, 0),
	TILE_TYPE.DIRT: Vector2i(0, 2),
	TILE_TYPE.CITY: Vector2i(0, 4),
}

const TILE_TYPE_VARIATIONS: Dictionary[TILE_TYPE, int] = {
	TILE_TYPE.GRASS: 4,
	TILE_TYPE.DIRT: 4,
	TILE_TYPE.CITY: 4,
}

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
	
	# Create biomes and assign them to tiles
	var biome_noise := FastNoiseLite.new()
	
	biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	biome_noise.seed = randi()
	biome_noise.frequency = 0.025
	biome_noise.fractal_octaves = 4
	biome_noise.fractal_lacunarity = 2
	biome_noise.fractal_gain = 0.5
	
	# Testing purposes
	var image_texture := ImageTexture.new()
	image_texture.set_image(biome_noise.get_image(Constants.MAP_SIZE.x, Constants.MAP_SIZE.y))
	test_image.texture = image_texture
	test_image.scale = Vector2(4, 4)
	test_image.rotation_degrees = 45
	test_image.position = Vector2(200, 100)
	
	# Create "biomes"
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Vector2i(Constants.MAP_SIZE) / 2
			
			var distance_from_origin: float = (map_coords - origin).length()
			
			var distance_scaled = distance_from_origin / (Constants.MAP_SIZE.length() * BIOME_FALLOFF)
			
			# Some value between 0.0 and 1.0
			var noise = biome_noise.get_noise_2dv(map_coords)
			
			var noise_clamped: float = clamp((noise + distance_scaled) , 0, 0.99)
			
			var scaled_value: float = noise_clamped * TILE_ATLAS_COORDS.size()
			
			var tile_type: int = TILE_TYPE.GRASS
			if (scaled_value > 0.7):
				tile_type = TILE_TYPE.DIRT
			if (scaled_value > 0.9):
				tile_type = TILE_TYPE.CITY
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
			
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			
			tile_data.set_custom_data("biome", tile_type)
	
	
	# Randomize tiles based on biome
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			
			var biome: int = tile_data.get_custom_data("biome")
			
			var scaled_value: float = randf() * (TILE_TYPE_VARIATIONS[biome] - 1)
			
			var modifier: int = floor(scaled_value)
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[biome] + Vector2i(modifier, 0)
			#print(atlas_coords)
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
