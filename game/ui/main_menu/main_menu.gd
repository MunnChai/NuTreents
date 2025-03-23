extends Control

const MAIN: PackedScene = preload("res://main.tscn")

func _ready():
	Global.game_state = Global.GameState.MAIN_MENU

func start_game():
	SceneLoader.transition_to_game()
