extends Control

const MAIN: PackedScene = preload("res://main.tscn")

@onready var start_button: Button = %StartButton

func _ready():
	Global.game_state = Global.GameState.MAIN_MENU
	NutreentsDiscordRPC.update_details("Navigating menus")
	
	start_button.pressed.connect(show_load_screen)

func show_load_screen():
	ScreenUI.add_menu(ScreenUI.load_menu)

func start_game():
	SceneLoader.transition_to_game()
	SfxManager.play_sound_effect("ui_click")
 
