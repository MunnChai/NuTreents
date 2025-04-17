extends Node

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	var session_data = SessionData.load_session_data()
	Global.update_globals()
	Global.game_state = Global.GameState.PLAYING
	NutreentsDiscordRPC.update_details("Growing a forest")
	
	call_deferred("_deferred_ready", session_data)

func _deferred_ready(session_data: Dictionary) -> void:
	if !session_data.is_empty():
		Global.set_seed(session_data["seed"])
	
	TreeManager.start_game()
	EnemyManager.start_game()
	Global.terrain_map.generate_map(false)
	if !session_data.is_empty():
		Global.structure_map.load_structures_from(session_data["structure_map"])
	
	

#func _process(delta):
	#if Input.is_action_just_pressed("debug_button"):
		#SceneLoader.transition_to_game_over()
