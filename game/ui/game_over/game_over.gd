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
	SceneLoader.transition_to_game()
	
