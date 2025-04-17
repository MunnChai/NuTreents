extends PanelContainer

const MENU_THEME = preload("res://ui/pause_menu/pause_menu_theme.tres")
const LOAD_BUTTON = preload("res://ui/save_and_load/load_button.tscn")

@onready var load_buttons = %LoadButtons

func _ready():
	create_load_buttons()

func create_load_buttons():
	for i in range(1, Global.NUM_SAVES + 1): # 1-NUM_SAVES, inclusive
		create_load_button(i)

func create_load_button(save_num: int = 1):
	var session_data = SessionData.load_session_data(save_num)
	
	var button = LOAD_BUTTON.instantiate()
	button.theme = MENU_THEME
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	load_buttons.add_child(button)
	button.set_button_info(save_num, session_data)
