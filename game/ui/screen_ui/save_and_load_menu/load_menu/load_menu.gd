class_name LoadMenu
extends ScreenMenu

const MENU_THEME = preload("res://ui/main_ui_theme.tres")
const LOAD_BUTTON = preload("load_button/load_button.tscn")

@onready var load_buttons: VBoxContainer = %LoadButtons
@onready var back_button: Button = %BackButton

var is_open := false

@onready var starting_position := position

## SCREEN MENU IMPLEMENTATION

func open(previous_menu: ScreenMenu) -> void:
	position = starting_position
	show()
	refresh()
	
	SfxManager.play_sound_effect("ui_click")
	
	## ANIMATION
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)

func close(next_menu: ScreenMenu) -> void:
	TweenUtil.scale_to(self, Vector2(0.9, 1.1), 0.05)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)
func _finish_close() -> void:
	hide()

func return_to(previous_menu: ScreenMenu) -> void:
	if previous_menu == ScreenUI.confirmation_menu:
		return
	
	## ANIMATION
	open(previous_menu)



func _ready():
	refresh()

func refresh() -> void:
	for btn in load_buttons.get_children():
		remove_child(btn)
		btn.queue_free()
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

func _on_back_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.exit_menu()
