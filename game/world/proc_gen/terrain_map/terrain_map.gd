class_name TerrainMap
extends TileMapLayer

# --- Enums and Base Constants ---
enum TileType {
	VOID = -1,
	GRASS = 0,
	DIRT = GRASS + 1,
	CITY = DIRT + 1,
	WATER = CITY + 1,
	ROAD = WATER + 1,
	SAND = ROAD + 1,
	SNOW = SAND + 1,
	ICE = SNOW + 1,
}

enum Biome {
	PLAINS = 1,
	DESERT = PLAINS + 1,
	SNOWY = DESERT + 1,
	CITY = SNOWY + 1,
}

const TILE_ATLAS_COORDS: Dictionary[TileType, Vector2i] = {
	TileType.GRASS: Vector2i(0, 0),
	TileType.DIRT: Vector2i(0, 2),
	TileType.CITY: Vector2i(0, 4),
	TileType.WATER: Vector2i(0, 14),
	TileType.ROAD: Vector2i(0, 6),
	TileType.SAND: Vector2i(0, 22),
	TileType.SNOW: Vector2i(0, 24),
	TileType.ICE: Vector2i(0, 26)
}

const TILE_TYPE_VARIATIONS: Dictionary[TileType, int] = {
	TileType.GRASS: 4,
	TileType.DIRT: 4,
	TileType.CITY: 4,
	TileType.WATER: 1,
	TileType.ROAD: 6,
	TileType.SAND: 4,
	TileType.SNOW: 6,
	TileType.ICE: 4,
}

const BIOME_TABLE: Array[Array] = [
	[Biome.PLAINS, Biome.PLAINS],
	[Biome.SNOWY, Biome.DESERT],
]

const BIOME_TILES: Dictionary[Biome, TileType] = {
	Biome.PLAINS: TileType.DIRT,
	Biome.DESERT: TileType.SAND,
	Biome.SNOWY: TileType.SNOW,
	Biome.CITY: TileType.CITY,
}


# --- Gameplay Effects & Properties ---
const TILE_EFFECTS: Dictionary[TileType, Dictionary] = {
	TileType.GRASS: {"water_consumption_modifier": 0.8, "water_production_modifier": 1.1},
	TileType.DIRT: {},
	TileType.SAND: {"water_consumption_modifier": 1.5, "water_production_modifier": 0.7, "fire_spread_modifier": 1.5},
	TileType.SNOW: {"water_consumption_modifier": 1.2, "fire_resistance_modifier": 0.5, "growth_rate_modifier": 0.9}
}

# --- Temperature System ---
const BIOME_TEMPERATURE_BASE: Dictionary[Biome, float] = {
	Biome.PLAINS: 15.0,
	Biome.DESERT: 30.0,
	Biome.SNOWY: -5.0,
	Biome.CITY: 18.0,
}
const TILE_TEMPERATURE_PROPERTIES: Dictionary[TileType, Dictionary] = {
	TileType.GRASS: {"heat_in": 1.0, "heat_out": 1.0},
	TileType.DIRT:  {"heat_in": 1.2, "heat_out": 0.9},
	TileType.CITY:  {"heat_in": 1.5, "heat_out": 0.7},
	TileType.WATER: {"heat_in": 2.0, "heat_out": 2.0},
	TileType.ROAD:  {"heat_in": 1.6, "heat_out": 0.6},
	TileType.SAND:  {"heat_in": 1.4, "heat_out": 0.8},
	TileType.SNOW:  {"heat_in": 0.5, "heat_out": 1.5}
}
const BASE_HEAT_TRANSFER_RATE: float = 0.1
var tile_temperature_data: Dictionary = {}

# --- General Constants ---
const SOURCE_ID: int = 0
const BIOME_FALLOFF = 2
const NUM_FACTORIES: int = 3

var world_size_settings: WorldSizeSettings

var biome_map: Dictionary[Vector2i, Biome] = {}
@onready var test_image: TextureRect = $CanvasLayer/TextureRect

func _ready() -> void:
	y_sort_enabled = true
	set_process(true)

func _input(event: InputEvent) -> void:
	if (TreeManager.is_mother_dead()):
		return
		
	#if (event is InputEventKey && event.is_action_pressed("generate_map")):
		#Global.new_seed()
		#regenerate_map()

func get_mouse_coords() -> Vector2:
	return get_local_mouse_position()

func _process(delta: float) -> void:
	for map_coords in tile_temperature_data.keys():
		update_tile_temperature(map_coords, delta)

# --- MAP GENERATION ---

func generate_map(world_size: Global.WorldSize = Global.WorldSize.SMALL, with_structures: bool = true) -> void:
	print("Generating map...")
	if not world_size in Global.WorldSize.values():
		world_size = Global.WorldSize.SMALL
	
	world_size_settings = WorldSettings.world_size_settings[world_size]
	
	initialize_map()
	var river_tiles: Array[Vector2i] = get_rivers()
	var city_coords: Array[Vector2i]
	var num_cities: int = randi_range(world_size_settings.min_cities, world_size_settings.max_cities)
	
	var angle: float = randf() * 2 * PI
	for i in range(0, num_cities):
		var map_coords: Vector2i = Global.ORIGIN + Vector2i(Vector2.RIGHT.rotated(angle) * world_size_settings.city_distance_from_origin)
		city_coords.append(map_coords)
		angle += 2 * PI / num_cities
		
	#var city_tiles = generate_cities(city_coords)
	generate_spawn()
	randomize_tiles()
	
	if with_structures:
		#call_deferred("generate_factories", city_coords)
		#call_deferred("generate_buildings", city_tiles)
		add_decor()
	
	generate_set_pieces()
	
	generate_rivers(river_tiles)
	call_deferred("initialize_temperature_data")

func regenerate_map() -> void:
	Global.structure_map.remove_all_structures()
	generate_map()

func initialize_map() -> void:
	var temp_noise := FastNoiseLite.new()
	temp_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	temp_noise.seed = Global.get_seed()
	temp_noise.frequency = 0.005
	temp_noise.fractal_octaves = 4
	temp_noise.fractal_lacunarity = 2
	temp_noise.fractal_gain = 0.5
	
	var humid_noise := FastNoiseLite.new()
	humid_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	humid_noise.seed = Global.get_seed() * 2
	humid_noise.frequency = 0.005
	humid_noise.fractal_octaves = 4
	humid_noise.fractal_lacunarity = 2
	humid_noise.fractal_gain = 0.5
	
	test_image.texture = NoiseTexture2D.new()
	test_image.texture.noise = temp_noise
	test_image.scale /= 2
	
	for x in get_map_x_range():
		for y in get_map_y_range():
			var map_coords: Vector2i = Vector2i(x ,y)
			var raw_temp_value: float = temp_noise.get_noise_2dv(map_coords)
			var scaled_temp_value: float = ((raw_temp_value + 1) / 2) * BIOME_TABLE[0].size() + 0.2
			var raw_humid_value: float = humid_noise.get_noise_2dv(map_coords)
			var scaled_humid_value: float = ((raw_humid_value + 1) / 2) * BIOME_TABLE.size()
			
			var biome: Biome = get_biome_from_stats(scaled_temp_value, scaled_humid_value)
			biome_map.set(map_coords, biome)
			
			var tile_type: int = BIOME_TILES[biome]
			set_cell_type(map_coords, tile_type)

# --- TEMPERATURE SYSTEM ---

func initialize_temperature_data() -> void:
	print("Initializing temperature system...")
	tile_temperature_data.clear()
	for x in get_map_x_range():
		for y in get_map_y_range():
			var map_coords := Vector2i(x, y)
			if get_cell_tile_data(map_coords) == null: continue
			var ambient_temp := _calculate_ambient_temperature(map_coords)
			tile_temperature_data[map_coords] = {"real_temp": ambient_temp, "entity_modifier": 0.0}

func update_tile_temperature(map_coords: Vector2i, delta: float) -> void:
	if not tile_temperature_data.has(map_coords): return
	var temp_data: Dictionary = tile_temperature_data[map_coords]
	var ambient_temp: float = _calculate_ambient_temperature(map_coords)
	var target_temp: float = ambient_temp + temp_data.entity_modifier
	var temp_difference: float = target_temp - temp_data.real_temp
	if abs(temp_difference) < 0.01: return
	var tile_type: TileType = get_tile_biome(map_coords)
	var heat_props: Dictionary = TILE_TEMPERATURE_PROPERTIES.get(tile_type, {"heat_in": 1.0, "heat_out": 1.0})
	var heat_modifier: float = heat_props.heat_in if temp_difference > 0 else heat_props.heat_out
	var temp_change: float = temp_difference * heat_modifier * BASE_HEAT_TRANSFER_RATE * delta
	temp_data.real_temp += temp_change

func _calculate_ambient_temperature(map_coords: Vector2i) -> float:
	var tile_data := get_cell_tile_data(map_coords)
	if not tile_data: return 15.0
	
	var biome_tile_type: TileType = tile_data.get_custom_data("biome")
	var biome: Biome

	# This match statement is more robust than a reverse dictionary lookup (find_key)
	# and directly handles all tile types, preventing null values.
	match biome_tile_type:
		TileType.DIRT:
			biome = Biome.PLAINS
		TileType.SAND:
			biome = Biome.DESERT
		TileType.SNOW:
			biome = Biome.SNOWY
		TileType.CITY, TileType.ROAD:
			biome = Biome.CITY
		TileType.GRASS:
			biome = Biome.PLAINS
		TileType.WATER:
			biome = Biome.PLAINS # Water assumes a neutral biome temperature
		_:
			biome = Biome.PLAINS # Failsafe for any other unknown tile type

	var base_temp: float = BIOME_TEMPERATURE_BASE.get(biome, 15.0)
	
	if not is_instance_valid(TimeManager.instance): return base_temp
	var time_of_day: float = TimeManager.instance.get_current_time()
	var time_offset: float = sin((time_of_day - 8.0) * (2.0 * PI) / 24.0) * 10.0
	
	var weather_modifier: float = 0.0
	if is_instance_valid(WeatherManager.instance):
		match WeatherManager.instance.current_weather:
			WeatherManager.WeatherType.CLEAR:
				weather_modifier = 2.0
			WeatherManager.WeatherType.RAIN:
				weather_modifier = -5.0
			WeatherManager.WeatherType.STORM:
				weather_modifier = -6.0

	return base_temp + time_offset + weather_modifier

# --- PUBLIC API & SAVE/LOAD ---

func get_real_temperature(map_coords: Vector2i) -> float:
	if tile_temperature_data.has(map_coords):
		return tile_temperature_data[map_coords].real_temp
	return 15.0

func add_temperature_modifier(center_coords: Vector2i, value: float, radius: int) -> void:
	for x in range(center_coords.x - radius, center_coords.x + radius + 1):
		for y in range(center_coords.y - radius, center_coords.y + radius + 1):
			var pos := Vector2i(x, y)
			if tile_temperature_data.has(pos) and pos.distance_to(center_coords) <= radius:
				tile_temperature_data[pos].entity_modifier += value

func get_tile_effects(pos: Vector2i) -> Dictionary:
	var tile_type: TileType = get_tile_biome(pos)
	if TILE_EFFECTS.has(tile_type):
		return TILE_EFFECTS[tile_type]
	return {}

func get_tile_biome(pos: Vector2i) -> TileType:
	var tile_data: TileData = get_cell_tile_data(pos)
	if tile_data == null: return TileType.VOID
	return tile_data.get_custom_data("biome")

func set_cell_type(pos: Vector2i, tile_type: TileType) -> void:
	if not TILE_ATLAS_COORDS.has(tile_type): return
	set_cell(pos, SOURCE_ID, TILE_ATLAS_COORDS[tile_type], 0)
	var tile_data = get_cell_tile_data(pos)
	if tile_data:
		tile_data.set_custom_data("biome", tile_type)

## This function is restored to fix the "nonexistent function" error.
func set_terrain_from_data(data: Dictionary) -> void:
	for pos: Vector2i in data.keys():
		var save_resource: TileDataResource = data[pos]
		set_cell_type(pos, save_resource.type)
	# Post-load logic like autotiling would go here.
	# The temperature system will be initialized after this by generate_map.

var animated_tiles: Dictionary[Vector2i, float]

const DEPETRIFIED_ID: int = 0
const PETRIFIED_ID: int = 1
const DEPETRIFICATION_EXPANSION_DELAY: float = 0.075
func depetrify_tile(pos: Vector2i, depetrify_around: bool = false) -> void:
	var tile_alt_id: int = get_cell_alternative_tile(pos)
	# Check to ensure this tile is petrified
	if tile_alt_id != PETRIFIED_ID:
		return
	# Depetrify the tile
	set_cell(pos, SOURCE_ID, get_cell_atlas_coords(pos), DEPETRIFIED_ID)
	
	## Handle animations
	if not MapUtility.tile_has_structure(pos):
		animate_tile(pos)
	
	await get_tree().create_timer(DEPETRIFICATION_EXPANSION_DELAY).timeout
	
	if depetrify_around:
		for surrounding_pos: Vector2i in get_surrounding_cells(pos):
			depetrify_tile(surrounding_pos, true)

const DEPETRIFY_ANIMATION_DURATION: float = 0.4
const DEPETRIFY_ANIM_OFFSET_ONE: float = 4
const DEPETRIFY_ANIM_OFFSET_TWO: float = -4
func animate_tile(pos: Vector2i) -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(set_animated_tile_offset.bind(pos), 0.0, DEPETRIFY_ANIM_OFFSET_ONE, DEPETRIFY_ANIMATION_DURATION / 3)
	tween.tween_method(set_animated_tile_offset.bind(pos), DEPETRIFY_ANIM_OFFSET_ONE, DEPETRIFY_ANIM_OFFSET_TWO, DEPETRIFY_ANIMATION_DURATION / 3)
	tween.tween_method(set_animated_tile_offset.bind(pos), DEPETRIFY_ANIM_OFFSET_TWO, 0.0, DEPETRIFY_ANIMATION_DURATION / 3)
	await tween.finished
	
	notify_runtime_tile_data_update()
	animated_tiles.erase(pos)

func set_animated_tile_offset(offset: float, pos: Vector2i) -> void:
	animated_tiles[pos] = offset
	notify_runtime_tile_data_update()

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return animated_tiles.has(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.texture_origin = Vector2(0, animated_tiles[coords])
	

# --- Positional Check Functions ---

func is_void(pos: Vector2i) -> bool:
	return get_cell_tile_data(pos) == null

func is_solid(pos: Vector2i) -> bool:
	if is_void(pos): return false
	return get_tile_biome(pos) != TileType.WATER

const FERTILE_TILE_TYPES: Array[TileType] = [
	TileType.GRASS, TileType.DIRT, TileType.SNOW, TileType.SAND
]
func is_fertile(pos: Vector2i) -> bool:
	if not is_solid(pos): return false
	return FERTILE_TILE_TYPES.has(get_tile_biome(pos))

func is_concrete(pos: Vector2i) -> bool:
	if is_fertile(pos): return false
	var biome: TileType = get_tile_biome(pos)
	return biome == TileType.CITY or biome == TileType.ROAD

# --- Rest of Generation Code ---

func get_biome_from_stats(temperature: float, humidity: float) -> Biome:
	var temp: int = floor(temperature)
	var humid: int = floor(humidity)
	return BIOME_TABLE[temp][humid]

func get_rivers() -> Array[Vector2i]:
	var river_noise := FastNoiseLite.new()
	river_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	river_noise.seed = randi()
	river_noise.frequency = 0.015
	river_noise.fractal_octaves = 4
	river_noise.fractal_lacunarity = 2
	river_noise.fractal_gain = 0.5
	
	var river_tiles: Array[Vector2i]
	
	for x in get_map_x_range():
		for y in get_map_y_range():
			var map_coords: Vector2i = Vector2i(x, y)
			var origin: Vector2i = Global.ORIGIN
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (world_size_settings.map_size.length() * BIOME_FALLOFF)
			var noise = river_noise.get_noise_2dv(map_coords)
			var noise_clamped: float = clamp((noise + distance_scaled), 0, 0.99)
			var scaled_value: float = noise_clamped * TILE_ATLAS_COORDS.size()
			
			if (scaled_value > 0.5 and scaled_value < 0.8):
				river_tiles.append(map_coords)
	return river_tiles

func generate_rivers(river_tiles: Array[Vector2i]) -> void:
	var to_remove: Array[Vector2i] = []
	for map_coords in river_tiles:
		var tile_data: TileData = get_cell_tile_data(map_coords)
		if (tile_data == null):
			to_remove.append(map_coords)
			continue
		
		var tile_type: int = tile_data.get_custom_data("biome")
		
		if (tile_type == null || tile_type != TileType.WATER):
			to_remove.append(map_coords)
	
	for map_coords in to_remove:
		river_tiles.erase(map_coords)
		
	for map_coords in river_tiles:
		if biome_map.get(map_coords) == Biome.SNOWY:
			set_cell_type(map_coords, TileType.ICE)
		else:
			set_cell_type(map_coords, TileType.WATER)

	set_cells_terrain_connect(river_tiles, 0, 1)

func generate_set_pieces() -> void:
	var total_num_set_pieces: int = world_size_settings.num_tree_unlock_set_pieces + world_size_settings.num_tech_point_set_pieces
	var set_piece_positions: Array[Vector2i] = get_multiple_radial_positions(total_num_set_pieces, world_size_settings.set_piece_radiuses, world_size_settings.num_set_pieces_per_circle)
	set_piece_positions.shuffle()
	
	var remaining_tree_unlocks: int = world_size_settings.num_tree_unlock_set_pieces
	var remaining_tech_points: int = world_size_settings.num_tech_point_set_pieces
	var tech_set_pieces: Array = SetPieceRegistry.get_tech_point_set_pieces()
	var tree_set_pieces: Array = SetPieceRegistry.get_tree_unlock_set_pieces()
	for pos: Vector2i in set_piece_positions:
		if remaining_tree_unlocks > 0:
			remaining_tree_unlocks -= 1
			
			var tile_type: TileType = get_tile_biome(pos)
			var biome: Biome = -999
			for biome_key: Biome in BIOME_TILES.keys():
				if BIOME_TILES[biome_key] == tile_type:
					biome = biome_key
					break
			
			if biome == -999:
				printerr("ERROR: Tile type does not match any Biome! terrain_map.gd::generate_set_pieces(): ", tile_type)
				return
			
			var new_set_piece: SetPiece = null
			for set_piece: SetPiece in tree_set_pieces:
				if set_piece.biome == biome:
					new_set_piece = set_piece
					break
			
			if new_set_piece == null:
				print("Null")
				continue
			
			create_set_piece(new_set_piece, pos)
			tree_set_pieces.erase(new_set_piece)
			
		elif remaining_tech_points > 0:
			remaining_tech_points -= 1
			
			# Get a random tech set piece, remove it from the list
			var set_piece: SetPiece = tech_set_pieces.pick_random()
			if not tech_set_pieces.has(set_piece) or set_piece == null:
				continue
			
			create_set_piece(set_piece, pos)
			tech_set_pieces.erase(set_piece)
			


func get_random_positions(amount: int) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	for i in range(0, amount):
		var x_range: Array = get_map_x_range()
		var x_rand: int = randi_range(x_range.front(), x_range.back())
		
		var y_range: Array = get_map_y_range()
		var y_rand: int = randi_range(y_range.front(), y_range.back())
		
		var pos_rand: Vector2i = Vector2i(x_rand, y_rand)
		positions.push_back(pos_rand)
	
	return positions

func get_radial_positions(amount: int, radius: float) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	var angle: float = randf() * 2 * PI
	for i in range(0, amount):
		var map_coords: Vector2i = Global.ORIGIN + Vector2i(Vector2.RIGHT.rotated(angle) * radius)
		positions.append(map_coords)
		angle += 2 * PI / amount
	
	return positions

func get_multiple_radial_positions(amount: int, radiuses: Array[float], pos_per_circle: Array[int] = []) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	
	var num_circles = radiuses.size()
	var num_pos_per_circle: int = int(amount / num_circles)
	
	for i in range(0, num_circles):
		var angle: float = randf() * 2 * PI
		var radius: float = radiuses[i]
		
		var num_pos_this_circle: int = num_pos_per_circle
		if not pos_per_circle.is_empty():
			num_pos_this_circle = pos_per_circle[i]
		for j in range(0, num_pos_this_circle):
			var map_coords: Vector2i = Global.ORIGIN + Vector2i(Vector2.RIGHT.rotated(angle) * radius)
			positions.append(map_coords)
			angle += 2 * PI / num_pos_this_circle
	
	return positions

func generate_cities(city_coords: Array[Vector2i]) -> Array[Vector2i]:
	var city_tiles: Array[Vector2i] = []
	for map_coords in city_coords:
		var tiles = generate_city(map_coords)
		city_tiles.append_array(tiles)
	
	var remove_duplicates: Dictionary[Vector2i, int]
	for tile in city_tiles:
		remove_duplicates[tile] = 0
	city_tiles = remove_duplicates.keys()
	
	return city_tiles

func generate_city(map_coords: Vector2i) -> Array[Vector2i]:
	var city_tiles: Array[Vector2i] = []
	for i in range(0, world_size_settings.num_city_drunkards):
		var tiles = walk_drunkard(map_coords, TileType.CITY, world_size_settings.city_drunkard_lifetime)
		city_tiles.append_array(tiles)
	
	var remove_duplicates: Dictionary[Vector2i, int] = {}
	for tile in city_tiles:
		remove_duplicates[tile] = 0
	city_tiles = remove_duplicates.keys()
	
	map_coords += Vector2i(1, 1)
	var road_tiles: Array[Vector2i] = []
	var num_roads = randi_range(world_size_settings.min_roads_per_city, world_size_settings.max_roads_per_city)
	var irreplaceable_tiles: Array[TileType] = [TileType.GRASS, TileType.DIRT, TileType.WATER, TileType.SAND, TileType.SNOW]
	for i in range(0, num_roads):
		var tiles = walk_drunkard_stride(map_coords, TileType.ROAD, world_size_settings.road_drunkard_lifetime, world_size_settings.min_road_length, world_size_settings.max_road_length, irreplaceable_tiles)
		road_tiles.append_array(tiles)
	
	var remove_road_duplicates: Dictionary[Vector2i, int] = {}
	for tile in road_tiles:
		remove_road_duplicates[tile] = 0
	road_tiles = remove_road_duplicates.keys()
	
	call_deferred("set_cells_terrain_connect", road_tiles, 0, 2, false)
	
	return city_tiles

func generate_spawn() -> void:
	var origin: Vector2i = Global.ORIGIN
	for i in range(0, world_size_settings.num_spawn_drunkards):
		walk_drunkard(origin, TileType.GRASS, world_size_settings.spawn_drunkard_lifetime, [])

func generate_factories(city_coords: Array[Vector2i]) -> void:
	for i in range(0, NUM_FACTORIES):
		if city_coords.is_empty(): break
		var coord = city_coords.pick_random()
		city_coords.erase(coord)
		var factory: Node2D = StructureRegistry.get_new_structure(Global.StructureType.FACTORY)
		var structure_map = Global.structure_map
		structure_map.add_structure(coord, factory)

func generate_buildings(city_tiles: Array[Vector2i]) -> void:
	for tile: Vector2i in city_tiles:
		var tile_data = get_cell_tile_data(tile)
		if (tile_data):
			var tile_type: int = tile_data.get_custom_data("biome")
			if (tile_type == TileType.CITY):
				var structure_map: BuildingMap = Global.structure_map
				var rand = randf()
				if (rand <= world_size_settings.building_frequency):
					var building: Node2D = StructureRegistry.get_new_structure(Global.StructureType.CITY_BUILDING)
					structure_map.add_structure(tile, building)

const CITY_DECOR_FREQUENCY = 0.3
const DIRT_DECOR_FREQUENCY = 0.01
const GRASS_DECOR_FREQUENCY = 0.025
const SAND_DECOR_FREQUENCY = 0.15
const SNOW_DECOR_FREQUENCY = 0.15
func add_decor() -> void:
	for x in get_map_x_range():
		for y in get_map_y_range():
			var pos = Vector2i(x, y)
			var structure_map = Global.structure_map
			var tile_data = get_cell_tile_data(pos)
			if (tile_data):
				var type = tile_data.get_custom_data("biome")
				var rand = randf()
				var decor: Node2D = StructureRegistry.get_new_structure(Global.StructureType.DECOR)
				
				if ((type == TileType.CITY and rand < CITY_DECOR_FREQUENCY) or 
					(type == TileType.DIRT and rand < DIRT_DECOR_FREQUENCY) or 
					(type == TileType.GRASS and rand < GRASS_DECOR_FREQUENCY) or
					(type == TileType.SAND and rand < SAND_DECOR_FREQUENCY) or
					(type == TileType.SNOW and rand < SNOW_DECOR_FREQUENCY)):
					var success: bool = structure_map.add_structure(pos, decor)

func create_set_piece(set_piece: SetPiece, grid_position: Vector2i) -> void:
	add_child(set_piece)
	
	grid_position += Vector2i(1, 0) # Slight offset for some reason
	
	var tiles: Dictionary[Vector2i, Dictionary] = set_piece.get_tile_info()
	#var tiles: Dictionary[Vector2i, Global.TileType] = set_piece.get_tiles()
	for offset: Vector2i in tiles.keys():
		var true_pos: Vector2i = grid_position + offset
		
		var info: Dictionary = tiles[offset]
		set_cell(true_pos, SOURCE_ID, info["atlas_coords"], info["alternative_id"])
		
		Global.structure_map.remove_structure(true_pos)
	
	var structures: Dictionary[Vector2i, Node2D] = set_piece.get_structures()
	for offset: Vector2i in structures.keys():
		var true_pos: Vector2i = grid_position + offset
		var structure: Node2D = structures[offset]
		structure.get_parent().remove_child(structure)
		Global.structure_map.add_structure(true_pos, structure, true)
	
	set_piece.queue_free()

func walk_drunkard(map_coords: Vector2i, tile_type: TileType, lifetime: int, irreplaceable_tiles: Array[TileType] = []) -> Array[Vector2i]:
	var drunkard_life: int = lifetime
	var current_coord: Vector2i = map_coords
	var visited: Array[Vector2i] = []
	while (drunkard_life > 0):
		var rand: int = randi_range(0, 3)
		var direction: Vector2i
		match (rand):
			0: direction = Vector2i.UP
			1: direction = Vector2i.DOWN
			2: direction = Vector2i.LEFT
			3: direction = Vector2i.RIGHT
		
		current_coord += direction
		
		if (current_coord.x >= get_map_x_range().back() or current_coord.y >= get_map_y_range().back() or
			current_coord.x < get_map_x_range().front() or current_coord.y < get_map_y_range().front()):
			drunkard_life -= 1
			continue
		
		var tile_data: TileData = get_cell_tile_data(current_coord)
		if (tile_data != null and irreplaceable_tiles.has(tile_data.get_custom_data("biome"))):
			drunkard_life -= 1
			continue
		
		set_cell_type(current_coord, tile_type)
		visited.append(current_coord)
		drunkard_life -= 1
	
	var remove_duplicates: Dictionary[Vector2i, int]
	for tile: Vector2i in visited:
		remove_duplicates[tile] = 0
	return remove_duplicates.keys()

func walk_drunkard_stride(start_coords: Vector2i, tile_type: TileType, lifetime: int, min_stride: int, max_stride: int, irreplaceable_tiles: Array[TileType]) -> Array[Vector2i]:
	var drunkard_life: int = lifetime
	var current_coord: Vector2i = start_coords
	var visited: Array[Vector2i] = []
	var stride: int = randi_range(min_stride, max_stride)
	
	while (drunkard_life > 0):
		var rand: int = randi_range(0, 3)
		var direction: Vector2i
		match (rand):
			0: direction = Vector2i.UP
			1: direction = Vector2i.DOWN
			2: direction = Vector2i.LEFT
			3: direction = Vector2i.RIGHT
		var curr_step = 0
		while (curr_step < stride):
			current_coord += direction
			if (current_coord.x >= get_map_x_range().back() or current_coord.y >= get_map_y_range().back() or
				current_coord.x < get_map_x_range().front() or current_coord.y < get_map_y_range().front()):
				curr_step += 1
				continue
			var tile_data = get_cell_tile_data(current_coord)
			if (tile_data and irreplaceable_tiles.has(tile_data.get_custom_data("biome"))):
				curr_step += 1
				continue
			
			set_cell_type(current_coord, tile_type)
			visited.append(current_coord)
			curr_step += 1
			
		drunkard_life -= 1
	
	var remove_duplicates: Dictionary[Vector2i, int]
	for tile: Vector2i in visited:
		remove_duplicates[tile] = 0
	return remove_duplicates.keys()


func walk_drunkard_targeted(start_coords: Vector2i, target_coords: Vector2i, tile_type: TileType, lifetime: int) -> bool:
	var drunkard_life: int = lifetime
	var current_coord: Vector2i = start_coords
	while (drunkard_life > 0):
		if (current_coord == target_coords):
			return true
		
		var target_direction: Vector2 = Vector2(target_coords - current_coord).normalized()
		var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
		directions.sort_custom(
			func(a: Vector2i, b: Vector2i):
				return (Vector2(a) - target_direction).length() < (Vector2(b) - target_direction).length()
		)
		
		var direction: Vector2i
		for i in range(0, directions.size() - 1):
			direction = directions[i]
			var rand: float = randf()
			if (rand < world_size_settings.highway_drunkard_accuracy):
				break
		
		current_coord += direction
		
		if (current_coord.x >= get_map_x_range().back() or current_coord.y >= get_map_y_range().back() or
			current_coord.x < get_map_x_range().front() or current_coord.y < get_map_y_range().front()):
			drunkard_life -= 1
			continue
		
		set_cell_type(current_coord, tile_type)
		drunkard_life -= 1
	
	return false

func randomize_tiles() -> void:
	for x in get_map_x_range():
		for y in get_map_y_range():
			randomize_tile(Vector2i(x ,y))

func randomize_tile(map_coords: Vector2i) -> void:
	var tile_data: TileData = get_cell_tile_data(map_coords)
	var biome: int = tile_data.get_custom_data("biome")
	var scaled_value: float = randf() * (TILE_TYPE_VARIATIONS[biome] - 1)
	var modifier: int = floor(scaled_value)
	
	var atlas_coords: Vector2i = TILE_ATLAS_COORDS[biome] + Vector2i(modifier, 0)
	set_cell(map_coords, SOURCE_ID, atlas_coords, 0)

func get_map_x_range() -> Array:
	return range(-world_size_settings.map_size.x / 2, world_size_settings.map_size.x / 2 + 1)

func get_map_y_range() -> Array:
	return range(-world_size_settings.map_size.y / 2, world_size_settings.map_size.y / 2 + 1)
