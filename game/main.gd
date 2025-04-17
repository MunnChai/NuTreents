extends Node

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	print(Global.session_id)
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

func load_world(session_data: Dictionary) -> void:
	# Set seed before world generation, for deterministic map gen
	Global.set_seed(session_data["seed"])
	
	TreeManager.start_game()
	EnemyManager.start_game()
	#Global.terrain_map.generate_map(false)
	Global.terrain_map.generate_map(true) # Temp until i get structure saving working
	
	#Global.structure_map.load_structures_from(session_data["structure_map"])

#func _process(delta):
	#if Input.is_action_just_pressed("debug_button"):
		#SceneLoader.transition_to_game_over()
