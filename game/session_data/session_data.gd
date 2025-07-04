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
func create_new_session_data(metadata: Dictionary):
	var config = ConfigFile.new()
	var full_path = SAVE_PATH + "/" + SAVE_NAME + str(metadata["session_id"]) + ".cfg"
	
	config.set_value(SECTION_METADATA, "world_name", metadata["world_name"])
	config.set_value(SECTION_METADATA, "seed", metadata["seed"])
	config.set_value(SECTION_METADATA, "world_size", metadata["world_size"])
	
	config.save(full_path)
	
	print("Created new metadata in: ", full_path)

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
	
	# Save current weather and time remaining
	var current_weather: WeatherManager.WeatherType = WeatherManager.instance.current_weather
	var weather_time_remaining: float = WeatherManager.instance.timer.time_left
	config.set_value(SECTION_SESSION, "current_weather", current_weather)
	config.set_value(SECTION_SESSION, "weather_time_remaining", weather_time_remaining)
	
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
		var tree: Node2D = TreeManager.tree_map[pos]
		
		tree_map[pos] = _create_twee_save_resource(tree)
	config.set_value(SECTION_SESSION, "tree_map", tree_map)
	
	# Save structures (including decor)
	var structure_map: Dictionary
	for pos in Global.structure_map.tile_scene_map:
		var structure: Node2D = Global.structure_map.tile_scene_map[pos]
		var save_resource = _create_structure_save_resource(structure)
		if !save_resource:
			continue
		structure_map[pos] = save_resource
	config.set_value(SECTION_SESSION, "structure_map", structure_map)
	
	# Save almanac info
	var trees: Array[Global.TreeType] = AlmanacInfo.get_trees()
	config.set_value(SECTION_SESSION, "almanac_trees", trees)
	var enemies: Array[Global.EnemyType] = AlmanacInfo.get_enemies()
	config.set_value(SECTION_SESSION, "almanac_enemies", enemies)
	
	# Save enemies + EnemyManager info
	var enemy_map: Dictionary
	for enemy: Node2D in EnemyManager.instance.get_enemies():
		var save_resource: EnemyDataResource = _create_enemy_save_resource(enemy)
		if !save_resource:
			continue
		var grid_position_component: GridPositionComponent = Components.get_component(enemy, GridPositionComponent)
		enemy_map[grid_position_component.get_pos()] = save_resource
	config.set_value(SECTION_SESSION, "enemy_map", enemy_map)
	config.set_value(SECTION_SESSION, "enemy_spawn_timer", EnemyManager.instance.enemy_spawn_timer)
	
	# Save currently purchased cards
	var purchased_cards: Array = ScreenUI.shop_menu.purchased_cards
	config.set_value(SECTION_SESSION, "purchased_cards", purchased_cards)
	
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
		#print("Loaded session data from: ", full_path)
		pass
	
	# Returns if this save slot is empty
	if not config.has_section(SECTION_METADATA):
		return {}
	
	if config.get_section_keys(SECTION_METADATA).is_empty():
		return {}
	
	# Get world name
	var world_name = config.get_value(SECTION_METADATA, "world_name", "ERR: WORLD_NAME")
	session_data["world_name"] = world_name
	
	# Get rng seed
	var session_seed = config.get_value(SECTION_METADATA, "seed")
	if session_seed is int:
		session_data["seed"] = session_seed
	else:
		session_data["seed"] = Global.new_seed()
		print("WARNING: Could not load value 'seed' from ", full_path)
	#print("Seed: ", session_seed)
	
	var world_size = config.get_value(SECTION_METADATA, "world_size", Global.WorldSize.MEDIUM)
	session_data["world_size"] = world_size
	
	# Get nutreents
	var nutreents = config.get_value(SECTION_SESSION, "nutreents", 0)
	session_data["nutreents"] = nutreents
	
	# Get time and day
	var current_day = config.get_value(SECTION_SESSION, "current_day", 1)
	var current_time = config.get_value(SECTION_SESSION, "current_time", 0)
	var total_time = config.get_value(SECTION_METADATA, "total_time", 0)
	session_data["current_day"] = current_day
	session_data["current_time"] = current_time
	session_data["total_time"] = total_time
	
	# Get weather data
	var current_weather = config.get_value(SECTION_SESSION, "current_weather", WeatherManager.WeatherType.CLEAR)
	var weather_time_remaining = config.get_value(SECTION_SESSION, "weather_time_remaining", 60.0)
	session_data["current_weather"] = current_weather
	session_data["weather_time_remaining"] = weather_time_remaining
	
	# Get almanac info
	var trees: Array[Global.TreeType] = config.get_value(SECTION_SESSION, "almanac_trees", ([] as Array[Global.TreeType]))
	session_data["almanac_trees"] = trees
	var enemies: Array[Global.EnemyType] = config.get_value(SECTION_SESSION, "almanac_enemies", ([] as Array[Global.TreeType]))
	session_data["almanac_enemies"] = enemies
	
	# Get EnemyManager info
	var enemy_map = config.get_value(SECTION_SESSION, "enemy_map", {})
	var enemy_spawn_timer = config.get_value(SECTION_SESSION, "enemy_spawn_timer", 0)
	session_data["enemy_map"] = enemy_map
	session_data["enemy_spawn_timer"] = enemy_spawn_timer
	
	# Get tiles
	var terrain_map = config.get_value(SECTION_SESSION, "terrain_map", {})
	session_data["terrain_map"] = terrain_map
	
	# Get trees
	var tree_map = config.get_value(SECTION_SESSION, "tree_map", {})
	session_data["tree_map"] = tree_map
	
	# Get structures
	var structure_map = config.get_value(SECTION_SESSION, "structure_map", {})
	session_data["structure_map"] = structure_map
	
	var purchased_cards = config.get_value(SECTION_SESSION, "purchased_cards", [])
	session_data["purchased_cards"] = purchased_cards
	
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

func _create_twee_save_resource(twee: Node2D) -> TweeDataResource:
	var save_resource: TweeDataResource = TweeDataResource.new()
	
	var stat_component: TweeStatComponent = Components.get_component(twee, TweeStatComponent)
	save_resource.type = stat_component.type
	
	var health_component: HealthComponent = Components.get_component(twee, HealthComponent)
	var behaviour_component: TweeBehaviourComponent = Components.get_component(twee, TweeBehaviourComponent)
	save_resource.hp = health_component.current_health
	var grow_timer: Timer = Components.get_component(twee, Timer, "GrowTimer")
	if grow_timer:
		save_resource.life_time_seconds = grow_timer.time_left
	save_resource.is_large = behaviour_component.is_large
	
	## SAVE ON FIRE AND TIME REMAINING
	var flammable_component: FlammableComponent = Components.get_component(twee, FlammableComponent, "", true)
	if flammable_component:
		save_resource.is_on_fire = flammable_component.is_on_fire()
		if save_resource.is_on_fire:
			save_resource.remaining_fire_lifetime = flammable_component.get_fire().lifetime_countdown
		else:
			save_resource.remaining_fire_lifetime = 0.0
	
	var animation_component: TweeAnimationComponent = Components.get_component(twee, TweeAnimationComponent)
	save_resource.sheet_id = animation_component.sheets.find(animation_component.sprite_2d.texture)
	
	save_resource.forest_water = TreeManager.forests[behaviour_component.forest].water
	
	if stat_component.type == Global.TreeType.TECH_TREE:
		save_resource.tech_slot = behaviour_component.tech_slot
	
	return save_resource

func _create_structure_save_resource(structure: Node2D) -> StructureDataResource:
	# Don't save trees
	if Components.has_component(structure, TweeStatComponent):
		return null
	
	var save_resource: StructureDataResource = StructureDataResource.new()
	
	var structure_behaviour_component: StructureBehaviourComponent = Components.get_component(structure, StructureBehaviourComponent)
	save_resource.flip_h = structure_behaviour_component.sprite_2d.flip_h
	save_resource.type = structure_behaviour_component.type
	
	match structure_behaviour_component.type:
		Global.StructureType.FACTORY, Global.StructureType.FACTORY_REMAINS:
			save_resource.tech_slot = structure_behaviour_component.tech_slot
		Global.StructureType.CITY_BUILDING:
			var atlas_texture: AtlasTexture = structure_behaviour_component.sprite_2d.texture
			save_resource.texture_region_position = atlas_texture.region.position
		Global.StructureType.DECOR:
			var atlas_texture: AtlasTexture = structure_behaviour_component.sprite_2d.texture
			save_resource.texture_region_position = atlas_texture.region.position
			save_resource.tile_type = structure_behaviour_component.tile_type
			save_resource.set_type_on_ready = structure_behaviour_component.set_type_on_ready
		Global.StructureType.PETRIFIED_TREE:
			save_resource.tree_type = Components.get_component(structure, PetrifiedTreeComponent).tree_type
	
	return save_resource

func _create_enemy_save_resource(enemy: Node2D) -> EnemyDataResource:
	var save_resource: EnemyDataResource = EnemyDataResource.new()
	
	var stat_component: EnemyStatComponent = Components.get_component(enemy, EnemyStatComponent)
	save_resource.type = stat_component.type
	var health_component: HealthComponent = Components.get_component(enemy, HealthComponent)
	save_resource.hp = health_component.current_health
	
	return save_resource

#endregion
