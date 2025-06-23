class_name TerrainMap
extends TileMapLayer

enum TileType {
	VOID = -1,
	GRASS = 0,
	DIRT = GRASS + 1,
	CITY = DIRT + 1,
	WATER = CITY + 1,
	ROAD = WATER + 1,
	DESERT = ROAD + 1,
}

const TILE_ATLAS_COORDS: Dictionary[TileType, Vector2i] = {
	TileType.GRASS: Vector2i(0, 0),
	TileType.DIRT: Vector2i(0, 2),
	TileType.CITY: Vector2i(0, 4),
	TileType.WATER: Vector2i(0, 14),
	TileType.ROAD: Vector2i(0, 6),
	TileType.DESERT: Vector2i(0, 22),
}

const TILE_TYPE_VARIATIONS: Dictionary[TileType, int] = {
	TileType.GRASS: 4,
	TileType.DIRT: 4,
	TileType.CITY: 4,
	TileType.WATER: 1,
	TileType.ROAD: 6,
	TileType.DESERT: 3,
}

const SOURCE_ID: int = 0
const BIOME_FALLOFF = 2

const NUM_FACTORIES: int = 3 

# The current world size settings being used to generate the world
var world_size_settings: WorldSizeSettings

#@onready var test_image: TextureRect = $CanvasLayer/TextureRect

func _ready() -> void:
	y_sort_enabled = true

#func _process(_delta: float) -> void:
	#pass
#
#func _input(event: InputEvent) -> void:
	#if (TreeManager.is_mother_dead()):
		## if mother died
		#return
	#if (event is InputEventKey && event.is_action_pressed("generate_map")):
		#generate_map()
		#Global.structure_map.remove_all_structures()
	#
	#if (Input.is_action_just_pressed("lmb")):
		#print(get_tile_biome(local_to_map(get_mouse_coords())))


func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_local_mouse_position()
	
	return mouse_screen_pos


func generate_map(world_size: Global.WorldSize = Global.WorldSize.SMALL, with_structures: bool = true) -> void:
	print("Generating map...") 
	
	if not world_size in Global.WorldSize.values():
		world_size = Global.WorldSize.SMALL
	
	world_size_settings = WorldSettings.world_size_settings[world_size]
	
	# Fill map with grass
	initialize_map()
	
	# Create rivers, and get river tiles for later
	var river_tiles: Array[Vector2i] = get_rivers()
	
	# Generate random cities
	var city_coords: Array[Vector2i]
	var num_cities: int = randi_range(world_size_settings.min_cities, world_size_settings.max_cities)
	
	var angle: float = randf() * 2 * PI
	for i in range(0, num_cities):
		
		var map_coords: Vector2i = Global.ORIGIN
		map_coords += Vector2i(Vector2.RIGHT.rotated(angle) * world_size_settings.city_distance_from_origin)
		city_coords.append(map_coords)
		
		angle += 2 * PI / num_cities
		
		#print("City: ", map_coords)
	
	# Generate roads between cities first
	generate_highways(city_coords)
	
	# Generate cities on top of roads
	var city_tiles = generate_cities(city_coords)
	
	# Create spawn area of grass
	generate_spawn()
	
	# Randomize tiles based on biome
	randomize_tiles()
	
	if with_structures:
		call_deferred("generate_factories", city_coords)
		call_deferred("generate_buildings", city_tiles)
		call_deferred("add_decor")
	
	# Generate rivers at the end of map generation, so autotiling works
	generate_rivers(river_tiles)


# Initializes the terrain tilemap to be fully grass tiles
func initialize_map() -> void:
	
	# Munn: leave commented in case of future noise use (is nice example)
	#var noise := FastNoiseLite.new()
	#noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	#noise.seed = randi()
	#noise.frequency = 0.005
	#noise.fractal_octaves = 4
	#noise.fractal_lacunarity = 2
	#noise.fractal_gain = 0.5
	
	#test_image.texture = NoiseTexture2D.new()
	#test_image.texture.noise = noise
	 
	for x in get_map_x_range():
		for y in get_map_y_range():
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var TileType: int = TileType.DIRT
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[TileType]
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			tile_data.set_custom_data("biome", TileType) 
	
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
	for x in get_map_x_range():
		for y in get_map_y_range():
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var origin: Vector2i = Global.ORIGIN
			
			var distance_from_origin: float = (map_coords - origin).length()
			var distance_scaled = distance_from_origin / (Global.MAP_SIZE.length() * BIOME_FALLOFF)
			
			# Some value between 0.0 and 1.0
			var noise = river_noise.get_noise_2dv(map_coords)
			var noise_clamped: float = clamp((noise + distance_scaled) , 0, 0.99)
			var scaled_value: float = noise_clamped * TILE_ATLAS_COORDS.size()
			
			if (scaled_value > 0.5 && scaled_value < 0.8):
				var TileType: int = TileType.WATER
			
				var atlas_coords: Vector2i = TILE_ATLAS_COORDS[TileType]
				
				set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
				
				var tile_data: TileData = get_cell_tile_data(map_coords)
				
				tile_data.set_custom_data("biome", TileType)
				
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
		if (tile_type == null || tile_type != TileType.WATER):
			to_remove.append(map_coords)
	
	for map_coords in to_remove:
		river_tiles.erase(map_coords)
	
	set_cells_terrain_connect(river_tiles, 0, 1)
	
	for map_coords in river_tiles:
		var tile_data: TileData = get_cell_tile_data(map_coords)
		tile_data.set_custom_data("biome", TileType.WATER)


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


func generate_highways(city_coords: Array[Vector2i]) -> void:
	
	for i in range(0, city_coords.size()):
		if (i == city_coords.size() - 1):
			return
		
		var curr_city: Vector2 = city_coords[i]
		var next_city: Vector2 = city_coords[i + 1]
		
		build_highway(curr_city, next_city)

func build_highway(city_i: Vector2i, city_j: Vector2i) -> void:
	
	for i in range(0, world_size_settings.num_highway_drunkards):
		walk_drunkard_targeted(city_i, city_j, TileType.GRASS, world_size_settings.highway_drunkard_lifetime)


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
	# Generate roads
	var road_tiles: Array[Vector2i] = []
	var num_roads = randi_range(world_size_settings.min_roads_per_city, world_size_settings.max_roads_per_city)
	var irreplaceable_tiles: Array[TileType] = [TileType.GRASS, TileType.DIRT, TileType.WATER, TileType.DESERT]
	for i in range(0, num_roads):
		var tiles = walk_drunkard_stride(map_coords, \
			TileType.ROAD, \
			world_size_settings.road_drunkard_lifetime, \
			world_size_settings.min_road_length, \
			world_size_settings.max_road_length, \
			irreplaceable_tiles)
		
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
		var coord = city_coords.pick_random()
		city_coords.erase(coord)
		
		var factory: Node2D = StructureRegistry.get_new_structure(Global.StructureType.FACTORY)
		
		var structure_map = Global.structure_map
		structure_map.add_structure(coord, factory)
 
func generate_buildings(city_tiles: Array[Vector2i]) -> void:
	
	# Generate buildings randomly
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
const DIRT_DECOR_FREQUENCY = 0.4
const GRASS_DECOR_FREQUENCY = 0.025
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
					(type == TileType.GRASS and rand < GRASS_DECOR_FREQUENCY)):
					var success: bool = structure_map.add_structure(pos, decor)
					if success:
						var decor_behaviour_component: DecorBehaviourComponent = Components.get_component(decor, DecorBehaviourComponent)
						decor_behaviour_component.set_decor_type(type)
				

func walk_drunkard(map_coords: Vector2i, tile_type: TileType, lifetime: int, irreplaceable_tiles: Array[TileType] = []) -> Array[Vector2i]:
	var drunkard_life: int = lifetime
	var current_coord: Vector2i = map_coords
	var visited: Array[Vector2i] = []
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
		
		if (current_coord.x >= get_map_x_range().back() || current_coord.y >= get_map_y_range().back()):
			drunkard_life -= 1
			continue
		if (current_coord.x < get_map_x_range().front() || current_coord.y < get_map_y_range().front()):
			drunkard_life -= 1
			continue
		
		var tile_data: TileData = get_cell_tile_data(current_coord)
		
		if (tile_data != null):
			var current_tile: TileType = tile_data.get_custom_data("biome")
			
			if (irreplaceable_tiles.find(current_tile) > -1):
				drunkard_life -= 1
				continue
		
		
		# Set to City Tile
		var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
		set_cell(current_coord, SOURCE_ID, atlas_coords, 0)
		tile_data = get_cell_tile_data(current_coord)
		tile_data.set_custom_data("biome", tile_type)
		visited.append(current_coord)
		
		drunkard_life -= 1
	
	var remove_duplicates: Dictionary[Vector2i, int]
	for tile: Vector2i in visited:
		remove_duplicates[tile] = 0
	visited = remove_duplicates.keys()
	
	return visited

func walk_drunkard_stride(start_coords: Vector2i, tile_type: TileType, lifetime: int, min_stride: int, max_stride: int, irreplaceable_tiles: Array[TileType]) -> Array[Vector2i]:
	var drunkard_life: int = lifetime
	var current_coord: Vector2i = start_coords
	var visited: Array[Vector2i] = []
	
	var stride: int = randi_range(min_stride, max_stride)
	
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
		var curr_step = 0
		while (curr_step < stride):
			current_coord += direction
			
			if (current_coord.x >= get_map_x_range().back() || current_coord.y >= get_map_y_range().back()):
				curr_step += 1
				continue
			if (current_coord.x < get_map_x_range().front() || current_coord.y < get_map_y_range().front()):
				curr_step += 1
				continue
			var tile_data = get_cell_tile_data(current_coord)
			if (tile_data):
				var type = tile_data.get_custom_data("biome")
				if (irreplaceable_tiles.has(type)):
					curr_step += 1
					continue
			
			# Set to City Tile
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[tile_type]
			set_cell(current_coord, SOURCE_ID, atlas_coords, 0)
			tile_data = get_cell_tile_data(current_coord)
			tile_data.set_custom_data("biome", tile_type)
			visited.append(current_coord)
			
			curr_step += 1
			
		drunkard_life -= 1
	
	var remove_duplicates: Dictionary[Vector2i, int]
	for tile: Vector2i in visited:
		remove_duplicates[tile] = 0
	visited = remove_duplicates.keys()
	
	return visited


func walk_drunkard_targeted(start_coords: Vector2i, target_coords: Vector2i, tile_type: TileType, lifetime: int) -> bool:
	var drunkard_life: int = lifetime
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
			if (rand < world_size_settings.highway_drunkard_accuracy):
				break
		
		# Move in direction
		current_coord += direction
		
		if (current_coord.x >= get_map_x_range().back() || current_coord.y >= get_map_y_range().back()):
			drunkard_life -= 1
			continue
		if (current_coord.x < get_map_x_range().front() || current_coord.y < get_map_y_range().front()):
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
	for x in get_map_x_range():
		for y in get_map_y_range():
			var map_coords: Vector2i = Vector2i(x ,y)
			
			var tile_data: TileData = get_cell_tile_data(map_coords)
			var biome: int = tile_data.get_custom_data("biome")
			var scaled_value: float = randf() * (TILE_TYPE_VARIATIONS[biome] - 1)
			var modifier: int = floor(scaled_value)
			
			var atlas_coords: Vector2i = TILE_ATLAS_COORDS[biome] + Vector2i(modifier, 0)
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
			
			tile_data = get_cell_tile_data(map_coords)
			tile_data.set_custom_data("biome", biome)


func get_map_x_range() -> Array:
	return range(-world_size_settings.map_size.x / 2, world_size_settings.map_size.x / 2 + 1)

func get_map_y_range() -> Array:
	return range(-world_size_settings.map_size.y / 2, world_size_settings.map_size.y / 2 + 1)


func get_tile_biome(pos: Vector2) -> TileType:
	var tile_data: TileData = get_cell_tile_data(pos)
	if tile_data == null:
		return TileType.VOID
	return tile_data.get_custom_data("biome")

func is_void(pos: Vector2) -> bool:
	var tile_data: TileData = get_cell_tile_data(pos)
	return tile_data == null

func is_solid(pos: Vector2) -> bool:
	if is_void(pos):
		return false
	var tile_data: TileData = get_cell_tile_data(pos)
	var biome = tile_data.get_custom_data("biome")
	return biome != TileType.WATER

func is_concrete(pos: Vector2) -> bool:
	if is_fertile(pos):
		return false
	var tile_data: TileData = get_cell_tile_data(pos)
	var biome = tile_data.get_custom_data("biome")
	return biome == TileType.CITY || biome == TileType.ROAD

## Can I plant a tree on this tile?
func is_fertile(pos: Vector2) -> bool:
	if not is_solid(pos):
		return false
	var tile_data: TileData = get_cell_tile_data(pos)
	var biome = tile_data.get_custom_data("biome")
	return biome == TileType.GRASS or biome == TileType.DIRT

func set_cell_type(pos: Vector2i, tile_type: TileType):
	set_cell(pos, SOURCE_ID, TILE_ATLAS_COORDS[tile_type], 0)


func set_terrain_from_data(data: Dictionary):
	
	for pos: Vector2i in data.keys():
		var save_resource: TileDataResource = data[pos]
		set_cell_type(pos, save_resource.type)
	
	# Set terrain autotile
