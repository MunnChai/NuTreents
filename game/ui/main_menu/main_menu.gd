extends Control

const MAIN: PackedScene = preload("res://main.tscn")

func _ready():
	Global.game_state = Global.GameState.MAIN_MENU
	NutreentsDiscordRPC.update_details("Navigating menus")

func start_game():
	SceneLoader.transition_to_tutorial()
	SfxManager.play_sound_effect("ui_click")
