extends Node

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	Global.update_globals()
	
	TreeManager.call_deferred("start_game")
	Global.game_state = Global.GameState.PLAYING

#func _process(delta):
	#if Input.is_action_just_pressed("debug_button"):
		#SceneLoader.transition_to_game_over()
