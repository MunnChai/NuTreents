class_name LoadMenu
extends ScreenMenu

const MENU_THEME = preload("res://ui/main_ui_theme.tres")
const LOAD_BUTTON = preload("load_button/load_button.tscn")

@onready var load_buttons: VBoxContainer = %LoadButtons
@onready var back_button: Button = %BackButton

var is_open := false

@onready var starting_position := position

var threads: Array[Thread]


func _ready():
	# Initialize threads
	threads.resize(Global.NUM_SAVES + 1)
	for i in range(1, Global.NUM_SAVES + 1):
		threads[i] = Thread.new()
	
	# Create buttons
	create_load_buttons()

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

func refresh() -> void:
	for i in range(1, Global.NUM_SAVES + 1):
		load_button_info_threaded(i)

func create_load_buttons():
	# Create the buttons first
	for i in range(1, Global.NUM_SAVES + 1): # 1-NUM_SAVES, inclusive
		create_load_button(i)
	
	# Then load button info
	refresh()

func create_load_button(save_num: int = 1):
	var load_button = LOAD_BUTTON.instantiate()
	load_button.theme = MENU_THEME
	load_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	load_buttons.add_child(load_button)

# Loads session data for this save_num on a separate thread
func load_button_info_threaded(save_num: int):
	threads[save_num].start(_get_button_info.bind(save_num))

# Gets session data, returns it
func _get_button_info(save_num: int):
	var session_data = SessionData.load_session_data(save_num)
	call_deferred("_set_button_info", save_num)
	return session_data

# Retrieves the session data from _get_button_info(), and sets the load button info
func _set_button_info(save_num: int):
	var session_data = threads[save_num].wait_to_finish()
	var load_button = get_load_button(save_num)
	load_button.call_deferred("set_button_info", save_num, session_data)

func get_load_buttons() -> Array:
	return load_buttons.get_children()

func get_load_button(save_num: int):
	return get_load_buttons()[save_num - 1]

func _on_back_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.exit_menu()

func _exit_tree():
	for i in range(1, Global.NUM_SAVES + 1):
		threads[i].wait_to_finish()
