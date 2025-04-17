extends Control

const MAIN: PackedScene = preload("res://main.tscn")

@onready var start_button: Button = %StartButton
@onready var load_screen = $CanvasLayer/LoadScreen

func _ready():
	Global.game_state = Global.GameState.MAIN_MENU
	NutreentsDiscordRPC.update_details("Navigating menus")
	
	start_button.pressed.connect(show_load_screen)
	load_screen.load_menu.back_button.pressed.connect(hide_load_screen)

func show_load_screen():
	load_screen.show_screen()

func hide_load_screen():
	load_screen.hide()

func start_game():
	SceneLoader.transition_to_game()
	SfxManager.play_sound_effect("ui_click")
