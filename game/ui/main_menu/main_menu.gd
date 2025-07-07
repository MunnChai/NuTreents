extends Control

const MAIN: PackedScene = preload("res://main.tscn")

@onready var start_button: Button = %StartButton

func _ready():
	Global.game_state = Global.GameState.MAIN_MENU
	NutreentsDiscordRPC.update_details("Navigating menus")
	
	start_button.pressed.connect(show_load_screen)

func show_load_screen():
	ScreenUI.add_menu(ScreenUI.load_menu)
	
	# --- BUG FIX ---
	# This line tells the button to give up focus immediately after being
	# pressed. This prevents the user from accidentally triggering the
	# action multiple times by spamming the Enter key.
	start_button.release_focus()

func start_game():
	SceneLoader.transition_to_game()
	SoundManager.play_global_oneshot(&"ui_click")
