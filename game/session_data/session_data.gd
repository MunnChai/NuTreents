extends Node

const SECTION_METADATA := "metadata"
const SECTION_SESSION := "session_data"

const SAVE_PATH := "user://session_data"
const SAVE_NAME := "session_"

# SAVED DATA:

var session_data: Dictionary = {}

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and Global.game_state == Global.GameState.PLAYING:
		save_session_data(Global.session_id)

#region SavingFunctions

# Create a new world, setting any initial metadata (name, seed, etc.)
func create_new_session_data(save_num: int, world_name: String = "New World", seed: int = randi()):
	var config = ConfigFile.new()
	var full_path = SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg"
	
	config.set_value(SECTION_METADATA, "world_name", world_name)
	config.set_value(SECTION_METADATA, "seed", seed)
	
	config.save(full_path)

# Save any information that has changed (tiles, structures, enemies, etc.)
func save_session_data(save_num: int = 1):
	var config = ConfigFile.new()
	var full_path = SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg"
	var err = config.load(full_path)
	
	# Save nutreents
	var nutreents: int = TreeManager.nutreents
	config.set_value(SECTION_SESSION, "nutreents", nutreents)
	
	# Save time and day
	var current_day: int = Global.clock.get_curr_day()
	var current_time: float = Global.clock.get_curr_day_sec()
	var total_time: float = Global.clock.get_current_sec()
	config.set_value(SECTION_SESSION, "current_day", current_day)
	config.set_value(SECTION_SESSION, "current_time", current_time)
	config.set_value(SECTION_METADATA, "total_time", total_time)
	
	# Save tiles
	var terrain_map: Dictionary
	for pos in Global.terrain_map.get_used_cells():
		var tile_data: TileData = Global.terrain_map.get_cell_tile_data(pos)
		var tile_type: TerrainMap.TileType = tile_data.get_custom_data("biome")
		
		var tile_save_data: TileDataResource = TileDataResource.new()
		tile_save_data.type = tile_type
		
		terrain_map[pos] = tile_save_data
	config.set_value(SECTION_SESSION, "terrain_map", terrain_map)
	
	# Save trees
	var tree_map: Dictionary
	for pos in TreeManager.tree_map:
		var tree: Twee = TreeManager.tree_map[pos]
		
		tree_map[pos] = _create_twee_save_resource(tree)
	config.set_value(SECTION_SESSION, "tree_map", tree_map)
	
	# Save structures (including decor)
	var structure_map: Dictionary
	for pos in Global.structure_map.tile_scene_map:
		var structure: Structure = Global.structure_map.tile_scene_map[pos]
		var save_resource = _create_structure_save_resource(structure)
		if !save_resource:
			continue
		structure_map[pos] = save_resource
	config.set_value(SECTION_SESSION, "structure_map", structure_map)
	
	# Save enemies + EnemyManager info
	var enemy_map: Dictionary
	for enemy: Enemy in EnemyManager.current_enemies:
		var save_resource: EnemyDataResource = _create_enemy_save_resource(enemy)
		if !save_resource:
			continue
		enemy_map[enemy.map_position] = save_resource
	config.set_value(SECTION_SESSION, "enemy_map", enemy_map)
	config.set_value(SECTION_SESSION, "enemy_spawn_timer", EnemyManager.enemy_spawn_timer)
	
	create_save_directory()
	
	err = config.save(full_path)
	if err != OK:
		print("WARNING: Failed to save session data!")
	else:
		print("Saved session data to: ", full_path)

# Load all data from session data
func load_session_data(save_num: int = 1) -> Dictionary:
	var session_data: Dictionary = {}
	var config = ConfigFile.new()
	var full_path = SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg"
	var err = config.load(full_path)
	if err != OK:
		return {}
	else:
		print("Loaded session data from: ", full_path)
	
	# Returns if this save slot is empty
	if config.get_section_keys(SECTION_METADATA).is_empty():
		return {}
	
	# Get world name
	var world_name = config.get_value(SECTION_METADATA, "world_name")
	if world_name is String:
		session_data["world_name"] = world_name
	else:
		session_data["world_name"] = "ERR_WORLD_NAME"
		print("WARNING: Could not load value 'world_name' from ", full_path)
	
	# Get rng seed
	var session_seed = config.get_value(SECTION_METADATA, "seed")
	if session_seed is int:
		session_data["seed"] = session_seed
	else:
		session_data["seed"] = Global.new_seed()
		print("WARNING: Could not load value 'seed' from ", full_path)
	#print("Seed: ", session_seed)
	
	# Get nutreents
	var nutreents = config.get_value(SECTION_SESSION, "nutreents")
	if nutreents is int:
		session_data["nutreents"] = nutreents
	else:
		session_data["nutreents"] = 0
		print("WARNING: Could not load value 'nutreents' from ", full_path)
	
	# Get time and day
	var current_day = config.get_value(SECTION_SESSION, "current_day")
	var current_time = config.get_value(SECTION_SESSION, "current_time")
	var total_time = config.get_value(SECTION_METADATA, "total_time")
	if current_day is int:
		session_data["current_day"] = current_day
	else:
		session_data["current_day"] = 1
		print("WARNING: Could not load value 'current_day' from ", full_path)
	if current_time is float:
		session_data["current_time"] = current_time
	else:
		session_data["current_time"] = 0
		print("WARNING: Could not load value 'current_time' from ", full_path)
	if total_time is float:
		session_data["total_time"] = total_time
	else:
		session_data["total_time"] = 0
		print("WARNING: Could not load value 'total_time' from ", full_path)
	
	# Get EnemyManager info
	var enemy_map = config.get_value(SECTION_SESSION, "enemy_map")
	var enemy_spawn_timer = config.get_value(SECTION_SESSION, "enemy_spawn_timer")
	if enemy_map is Dictionary:
		session_data["enemy_map"] = enemy_map
	else:
		session_data["enemy_map"] = {}
		print("WARNING: Could not load value 'enemy_map' from ", full_path)
	if enemy_spawn_timer is float:
		session_data["enemy_spawn_timer"] = enemy_spawn_timer
	else:
		session_data["enemy_spawn_timer"] = 0
		print("WARNING: Could not load value 'enemy_spawn_timer' from ", full_path)
	
	# Get tiles
	var terrain_map = config.get_value(SECTION_SESSION, "terrain_map")
	if terrain_map is Dictionary:
		session_data["terrain_map"] = terrain_map
	else:
		session_data["terrain_map"] = {}
		print("WARNING: Could not load value 'terrain_map' from ", full_path)
	
	# Get trees
	var tree_map = config.get_value(SECTION_SESSION, "tree_map")
	if tree_map is Dictionary:
		session_data["tree_map"] = tree_map
	else:
		session_data["tree_map"] = {}
		print("WARNING: Could not load value 'tree_map' from ", full_path)
	
	# Get structures
	var structure_map = config.get_value(SECTION_SESSION, "structure_map")
	if structure_map is Dictionary:
		session_data["structure_map"] = structure_map
	else:
		session_data["structure_map"] = {}
		print("WARNING: Could not load value 'structure_map' from ", full_path)
	
	return session_data

# Set a value 
func set_session_data(section_name: String, save_num: int, key: String, value: Variant):
	var config = ConfigFile.new()
	var full_path = SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg"
	var err = config.load(full_path)
	if err != OK:
		print("WARNING: Failed to load session data: ", full_path)
		return
	
	config.set_value(section_name, key, value)
	
	config.save(full_path)

# Empties a session
func clear_session_data(save_num: int = 1):
	var config = ConfigFile.new()
	var full_path = SAVE_PATH + "/" + SAVE_NAME + str(save_num) + ".cfg"
	var err = config.load(full_path)
	# Don't "clear" a file that doesn't even exist
	if err != OK:
		return
	
	config.clear()
	
	config.save(full_path)

#endregion


# Creates a directory in the User directory if it does not already exist
func create_save_directory() -> void:
	if !DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)


#region SaveResources

func _create_twee_save_resource(twee: Twee) -> TweeDataResource:
	var save_resource: TweeDataResource = TweeDataResource.new()
	
	save_resource.type = twee.type
	
	save_resource.hp = twee.hp
	save_resource.life_time_seconds = twee.life_time_seconds
	save_resource.is_large = twee.is_large
	
	save_resource.sheet_id = twee.sheets.find(twee.sprite.texture)
	
	save_resource.forest_water = TreeManager.forests[twee.forest].water
	
	return save_resource

func _create_structure_save_resource(structure: Structure) -> StructureDataResource:
	# Don't save trees
	if structure is Twee:
		return null
	
	var save_resource: StructureDataResource = StructureDataResource.new()
	
	save_resource.flip_h = structure.sprite_2d.flip_h
	
	if structure is Factory:
		save_resource.tech_slot = structure.tech_slot
		save_resource.type = structure.structure_type
	elif structure is CityStructure:
		var atlas_texture: AtlasTexture = structure.sprite_2d.texture
		save_resource.texture_region_position = atlas_texture.region.position
		save_resource.type = structure.structure_type
	elif structure is Decor:
		var atlas_texture: AtlasTexture = structure.sprite_2d.texture
		save_resource.texture_region_position = atlas_texture.region.position
		save_resource.tile_type = structure.tile_type
		save_resource.type = structure.structure_type
	
	return save_resource

func _create_enemy_save_resource(enemy: Enemy) -> EnemyDataResource:
	var save_resource: EnemyDataResource = EnemyDataResource.new()
	
	save_resource.type = enemy.type
	save_resource.hp = enemy.current_health
	
	return save_resource

#endregion
