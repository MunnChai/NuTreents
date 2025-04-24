class_name ScreenUI
extends Control

const PAUSE_MENU = preload("res://ui/screen_ui/pause_menu/pause_menu.tscn")

var is_open := false

var menu_stack := []
## Adds a menu to the UI and opens it
## Opens the ScreenUI if it is not open
func add_menu(menu: Control) -> void:
	menu_stack.push_back(menu)
	if menu.get_parent() == null:
		add_child(menu)
	if not is_open:
		open()
	if menu.has_method("open"):
		menu.open()
## Pops the latest menu in the UI and closes it
## Closes the ScreenUI if it was the last menu
func exit_menu() -> Control:
	var menu = menu_stack.pop_back()
	if menu_stack.is_empty():
		close()
	if menu.has_method("close"):
		menu.close()
	var new_menu := get_active_menu()
	if new_menu != null and new_menu.has_method("return_to"):
		new_menu.return_to()
	return menu
## Clears the stack and closes the ScreenUI
func terminate_stack() -> void:
	for menu: Control in menu_stack:
		if menu.has_method("close_on_termination"):
			menu.close_on_termination()
		elif menu.has_method("close"):
			menu.close()
	menu_stack = []
## Returns the menu that is currently at the top of the stack
func get_active_menu() -> Control:
	return menu_stack.back()

func _ready() -> void:
	Global.screen_ui = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	jump_to_closed()

func open() -> void:
	if is_open:
		return
	is_open = true
	%Dimmer.show()
	TweenUtil.fade(%Dimmer, 1.0, 0.2)

func close() -> void:
	if not is_open:
		return
	is_open = false
	TweenUtil.fade(%Dimmer, 0.0, 0.2).finished.connect(_fade_finished)
func _fade_finished() -> void:
	%Dimmer.hide()

func jump_to_closed() -> void:
	is_open = false
	%Dimmer.hide()
	%Dimmer.modulate.a = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if not is_open:
			var new_menu := PAUSE_MENU.instantiate()
			add_menu(new_menu)
			return
	
	if Input.is_action_just_pressed("pause"):
		if is_open:
			exit_menu()
