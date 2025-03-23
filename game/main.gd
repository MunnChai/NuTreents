extends Node

# Parent _ready() is called after all children _ready()s have been called, 
# so entire scene will be done when this is called
func _ready():
	Global.update_globals()
	
	TreeManager.call_deferred("start_game")
	Global.game_state = Global.GameState.PLAYING
