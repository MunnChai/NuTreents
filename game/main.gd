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
	
	TreeManager.start_game()
	EnemyManager.start_game()
	Global.terrain_map.generate_map()
	Global.fog_map.init()

func load_world(session_data: Dictionary) -> void:
	# Set seed before world generation, for deterministic map gen
	Global.set_seed(session_data["seed"])
	
	TreeManager.start_game()
	EnemyManager.start_game()
	Global.terrain_map.generate_map(false) # Generate map without buildings
	Global.fog_map.init()
	
	TreeManager.start_game()
	
	# Set nutreents
	TreeManager.nutreents = session_data["nutreents"]
	
	# Set time and day
	Global.clock.set_current_sec(session_data["total_time"])
	Global.clock.set_curr_day(session_data["current_day"])
	Global.clock.set_curr_day_sec(session_data["current_time"])
	
	# Place trees
	var tree_map: Dictionary = session_data["tree_map"]
	for pos in tree_map.keys():
		var tree_resource: TweeDataResource = tree_map[pos]
		
		if (tree_resource.type == Global.TreeType.MOTHER_TREE):
			continue
		
		var tree: Twee = TreeRegistry.get_new_twee(tree_resource.type)
		TreeManager.place_tree(tree, pos)
		
		tree.apply_data_resource(tree_resource)
	
	Global.terrain_map.set_terrain_from_data(session_data["terrain_map"])
	Global.structure_map.set_structures_from_data(session_data["structure_map"])
	
	# Load enemies
	EnemyManager.load_enemies_from(session_data["enemy_map"])
	EnemyManager.enemy_spawn_timer = session_data["enemy_spawn_timer"]
