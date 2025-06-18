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
	Global.terrain_map.generate_map(Global.current_world_size)
	Global.fog_map.init()
	
	TreeManager.start_game()
	
	ScreenUI.shop_menu.reset_shop_cards()
	
	# Save metadata and session data together, so we don't end up with one without the other in a save file
	SessionData.call_deferred("create_new_session_data", Global.get_metadata())
	SessionData.call_deferred("save_session_data", Global.session_id)

func load_world(session_data: Dictionary) -> void:
	# Set seed before world generation, for (hopefully) deterministic map gen
	Global.set_seed(session_data["seed"])
	Global.current_world_size = session_data["world_size"]
	
	EnemyManager.instance.start_game()
	Global.terrain_map.generate_map(session_data["world_size"], false) # Generate map without buildings
	Global.fog_map.init()
	
	TreeManager.start_game()
	
	# Set nutreents
	TreeManager.nutreents = session_data["nutreents"]
	
	# Set time and day
	Global.clock.set_current_sec(session_data["total_time"])
	Global.clock.set_curr_day(session_data["current_day"])
	Global.clock.set_curr_day_sec(session_data["current_time"])
	
	# Set terrain and structures
	Global.terrain_map.set_terrain_from_data(session_data["terrain_map"])
	Global.terrain_map.randomize_tiles()
	Global.structure_map.set_structures_from_data(session_data["structure_map"])
	
	# Place trees
	var tree_map: Dictionary = session_data["tree_map"]
	for pos in tree_map.keys():
		var tree_resource: TweeDataResource = tree_map[pos]
		
		if (tree_resource.type == Global.TreeType.MOTHER_TREE):
			continue
		
		var tree: Node2D = TreeRegistry.get_new_twee(tree_resource.type)
		TreeManager.place_tree(tree, pos)
		
		var tree_behaviour_component: TweeBehaviourComponent = Components.get_component(tree, TweeBehaviourComponent)
		tree_behaviour_component.apply_data_resource(tree_resource)
	
	# Load enemies
	EnemyManager.instance.load_enemies_from(session_data["enemy_map"])
	EnemyManager.instance.enemy_spawn_timer = session_data["enemy_spawn_timer"]
	
	# Add purchased cards to tree menu
	ScreenUI.shop_menu.reset_shop_cards() # Reset the state of the shop menu first
	ScreenUI.shop_menu.purchased_cards = session_data["purchased_cards"]
	for tree_type: Global.TreeType in ScreenUI.shop_menu.purchased_cards:
		TreeMenu.instance.add_tree_card(tree_type)
		ScreenUI.shop_menu.disable_card_of_type(tree_type)
