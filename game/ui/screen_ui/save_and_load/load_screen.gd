extends Control

@onready var load_menu = $LoadMenu
@onready var new_world_menu = $NewWorldMenu

var is_open: bool = false

func _ready() -> void:
	new_world_menu.back_button.pressed.connect(
		func():
			close_new_world_menu()
			Global.session_id = 0
	)
	
	var load_buttons = load_menu.get_load_buttons()
	for load_button in load_buttons:
		if !load_button.has_save_file:
			connect_button_open_new_world_menu(load_button)
		
		load_button.delete_button.pressed.connect(connect_button_open_new_world_menu.bind(load_button))

func connect_button_open_new_world_menu(load_button):
	load_button.button.pressed.connect(
		func():
			open_new_world_menu()
			Global.session_id = load_button.save_num
	)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if new_world_menu.is_open:
			close_new_world_menu()
		else:
			hide_screen()

func open_new_world_menu() -> void:
	# TODO: insert animations here...
	load_menu.hide()
	new_world_menu.open()

func close_new_world_menu() -> void:
	# TODO: insert animations here...
	load_menu.show()
	new_world_menu.close()

func show_screen() -> void:
	show()
	is_open = true
	
	# TODO: insert animations here...
	load_menu.show()
	new_world_menu.close()

func hide_screen() -> void:
	hide()
	is_open = false
