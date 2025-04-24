extends PanelContainer

const MENU_THEME = preload("res://ui/main_ui_theme.tres")
const LOAD_BUTTON = preload("res://ui/screen_ui/save_and_load/load_menu/load_button/load_button.tscn")

@onready var load_buttons: VBoxContainer = %LoadButtons
@onready var back_button: Button = %BackButton

var is_open := false

func _ready():
	create_load_buttons()

func create_load_buttons():
	for i in range(1, Global.NUM_SAVES + 1): # 1-NUM_SAVES, inclusive
		create_load_button(i)

func create_load_button(save_num: int = 1):
	var session_data = SessionData.load_session_data(save_num)
	
	var load_button = LOAD_BUTTON.instantiate()
	load_button.theme = MENU_THEME
	load_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	load_buttons.add_child(load_button)
	load_button.set_button_info(save_num, session_data)


func get_load_buttons() -> Array:
	return load_buttons.get_children()
