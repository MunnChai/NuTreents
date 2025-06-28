class_name GameOverScreen
extends Control

const FADE_DURATION: float = 2.0

func _ready():
	Global.game_state = Global.GameState.GAME_OVER

func return_to_main_menu():
	SfxManager.play_sound_effect("ui_click")
	SceneLoader.transition_to_main_menu()

func retry():
	SfxManager.play_sound_effect("ui_click")
	
	# --- BUG FIX ---
	# Instead of loading a new, empty game session, we now explicitly reload the
	# session data from the current save file using the existing Global.session_id.
	# This ensures that when you retry, you are reloading your actual world.
	var session_to_reload = SessionData.load_session_data(Global.session_id)
	SceneLoader.transition_to_game(session_to_reload)
