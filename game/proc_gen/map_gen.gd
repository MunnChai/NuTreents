extends TileMapLayer

@onready var test_image: TextureRect = $CanvasLayer/TextureRect
@onready var highlight: Sprite2D = $Highlight

const SOURCE_ID: int = 1

enum TILE_TYPE {
	DIRT = 0,
	GRASS = DIRT + 1,
	CEMENT = GRASS + 1,
}

const TILE_ATLAS_COORDS: Dictionary[TILE_TYPE, Vector2i] = {
	TILE_TYPE.DIRT: Vector2i(0, 0),
	TILE_TYPE.GRASS: Vector2i(0, 2),
	TILE_TYPE.CEMENT: Vector2i(0, 4),
}

const TILE_TYPE_VARIATIONS: Dictionary[TILE_TYPE, int] = {
	TILE_TYPE.DIRT: 2,
	TILE_TYPE.GRASS: 3,
	TILE_TYPE.CEMENT: 6,
}

func _ready() -> void:
	generate_map()

func _process(delta: float) -> void:
	
	update_highlight()

func _input(event: InputEvent) -> void:
	
	if (event is InputEventKey && event.is_action_pressed("generate_map")):
		generate_map()
	
	if (Input.is_action_pressed("lmb")):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		add_cell(map_coords)
	
	if (Input.is_action_pressed("rmb")):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		remove_cell(map_coords)

func update_highlight() -> void:
	var map_coords: Vector2i = local_to_map(get_mouse_coords())
	
	var tile_data: TileData = get_cell_tile_data(map_coords)
	
	if (tile_data == null):
		highlight.visible = false
	else:
		highlight.visible = true
		highlight.position = map_to_local(map_coords)

func add_cell(map_coords: Vector2i) -> bool:
	
	var atlas_coords: Vector2i = Vector2i(0, 0)
	
	set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
	
	return true

func remove_cell(map_coords: Vector2i) -> bool:
	
	var atlas_coords: Vector2i = Vector2i(0, 0)
	
	erase_cell(map_coords)
	
	return true


func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_local_mouse_position()
	
	return mouse_screen_pos


func generate_map() -> void:
	print("Generating map...")
	
	# Create biomes and assign them to tiles
	var biome_noise := FastNoiseLite.new()
	
	biome_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
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
	
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			# Some value between 0.0 and 1.0
			var noise_value: float = clamp((biome_noise.get_noise_2dv(map_coords) + 1), 0, 1)
			
			if (noise_value == 1):
				noise_value = 0
			
			var scaled_value: float = noise_value * TILE_ATLAS_COORDS.size()
			
			var tile_type: int = floor(scaled_value)
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
			
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			
			tile_data.set_custom_data("biome", tile_type)
	
	
	# Get random tiles based on noise and biome
	var noise: FastNoiseLite = FastNoiseLite.new()
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 2
	noise.fractal_gain = 0.5
	
	for x in range(0, Constants.MAP_SIZE.x):
		for y in range(0, Constants.MAP_SIZE.y):
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			
			var biome: int = tile_data.get_custom_data("biome")
			
			# Some value between 0.0 and 1.0
			var noise_value: float = clamp((noise.get_noise_2dv(map_coords) + 1), 0, 1)
			
			var scaled_value: float = noise_value * (TILE_TYPE_VARIATIONS[biome] - 1)
			
			var modifier: int = floor(scaled_value)
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[biome] + Vector2i(modifier, 0)
			#print(atlas_coords)
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
