extends Node

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	var session_data = Global.session_data
	
	Global.update_globals()
	Global.game_state = Global.GameState.PLAYING
	NutreentsDiscordRPC.update_details("Growing a forest")
	
	if session_data.is_empty():
		call_deferred("create_new_world")
	else:
		call_deferred("load_world", session_data)

func create_new_world() -> void:
	# Set seed before world generation, for deterministic map gen
	Global.set_seed(Global.get_seed())
	
	EnemyManager.instance.start_game()
	Global.fog_map.init()
	Global.terrain_map.generate_map(Global.current_world_size)
	
	TreeManager.start_game()
	
	# Save metadata and session data together, so we don't end up with one without the other in a save file
	SessionData.call_deferred("create_new_session_data", Global.get_metadata())
	SessionData.call_deferred("save_session_data", Global.session_id)
	
	# set almanac info
	AlmanacInfo.add_tree(Global.TreeType.MOTHER_TREE)
	AlmanacInfo.add_tree(Global.TreeType.DEFAULT_TREE)
	AlmanacInfo.add_tree(Global.TreeType.WATER_TREE)
	AlmanacInfo.add_tree(Global.TreeType.GUN_TREE)
	print("new world trees", AlmanacInfo.get_trees())
	
	ResearchTree.instance.reset_unlocked_nodes()
	ResearchTree.instance.set_tech_points(0)

func load_world(session_data: Dictionary) -> void:
	# Set seed before world generation, for (hopefully) deterministic map gen
	Global.set_seed(session_data["seed"])
	Global.current_world_size = session_data["world_size"]
	
	EnemyManager.instance.start_game()
	Global.fog_map.init()
	#Global.terrain_map.generate_map(session_data["world_size"], false) # Generate map without buildings
	
	TreeManager.start_game()
	
	# Set nutreents
	TreeManager.nutreents = session_data["nutreents"]
	
	# Set time and day
	Global.clock.set_current_sec(session_data["total_time"])
	Global.clock.set_curr_day(session_data["current_day"])
	Global.clock.set_curr_day_sec(session_data["current_time"])
	
	# --- BUG FIX ---
	# After setting the time data, we must call a function to force the
	# clock's visual state (the day/night animation) to update immediately.
	Global.clock.force_update_visuals()
	
	# Set weather
	WeatherManager.instance.switch_to(session_data["current_weather"], session_data["weather_time_remaining"])
	
	# Set terrain and structures
	Global.terrain_map.set_terrain_from_data(session_data["terrain_map"])
	#Global.terrain_map.randomize_tiles()
	Global.structure_map.set_structures_from_data(session_data["structure_map"], false)
	
	# Place trees
	var tree_map: Dictionary = session_data["tree_map"]
	for pos in tree_map.keys():
		var tree_resource: TweeDataResource = tree_map[pos]
		
		if (tree_resource.type == Global.TreeType.MOTHER_TREE):
			var mother_twee = TreeManager.get_twee(pos)
			var health_component: HealthComponent = Components.get_component(mother_twee, HealthComponent)
			health_component.call_deferred("set_current_health", tree_resource.hp)
			continue
		
		var tree: Node2D = TreeRegistry.get_new_twee(tree_resource.type)
		TreeManager.place_tree(tree, pos)
		
		var tree_behaviour_component: TweeBehaviourComponent = Components.get_component(tree, TweeBehaviourComponent)
		tree_behaviour_component.call_deferred("apply_data_resource", tree_resource)
	
	# Load enemies
	EnemyManager.instance.load_enemies_from(session_data["enemy_map"])
	EnemyManager.instance.enemy_spawn_timer = session_data["enemy_spawn_timer"]
	
	# Add unlocked cards to tree menu
	for tree_type: Global.TreeType in session_data["purchased_cards"]:
		TreeMenu.instance.add_tree_card(tree_type)
	
	# Add almanac info
	AlmanacInfo.set_trees(session_data["almanac_trees"])
	AlmanacInfo.set_trees(session_data["almanac_enemies"])
	
	# Set unlocked research nodes
	ResearchTree.instance.reset_unlocked_nodes()
	ResearchTree.instance.set_unlocked_nodes(session_data["unlocked_research"])
	ResearchTree.instance.set_tech_points(session_data["num_tech_points"])
