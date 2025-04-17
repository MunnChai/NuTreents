extends Node

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	var session_data = SessionData.load_session_data()
	Global.set_seed(session_data["seed"])
	
	Global.update_globals()
	TreeManager.call_deferred("start_game")
	EnemyManager.call_deferred("start_game")
	Global.game_state = Global.GameState.PLAYING
	NutreentsDiscordRPC.update_details("Growing a forest")

#func _process(delta):
	#if Input.is_action_just_pressed("debug_button"):
		#SceneLoader.transition_to_game_over()
