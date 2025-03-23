extends Control

const MAIN: PackedScene = preload("res://main.tscn")

func start_game():
	SceneLoader.transition_to_game()
