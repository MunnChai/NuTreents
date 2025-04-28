class_name ScreenUIGlobal
extends CanvasLayer

## SCREEN UI AUTOLOAD

## ---

@onready var menu_layer = %MenuLayer

@onready var pause_menu: PauseMenu = %PauseMenu
@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var load_menu: LoadMenu = %LoadMenu

var is_open := false

var menu_stack: Array[ScreenMenu] = []
## Adds a menu to the UI and opens it
## Opens the ScreenUI if it is not open
func add_menu(menu: ScreenMenu) -> void:
	menu_stack.push_back(menu)
	if menu.get_parent() == null:
		menu_layer.add_child(menu)
	if not is_open:
		open()
	if menu.has_method("open"):
		menu.open(get_previously_active_menu())
## Pops the latest menu in the UI and closes it
## Closes the ScreenUI if it was the last menu
func exit_menu() -> ScreenMenu:
	var menu = menu_stack.pop_back()
	var new_menu := get_active_menu()
	if menu.has_method("close"):
		menu.close(new_menu)
	if menu_stack.is_empty():
		close()
		return
	if new_menu != null and new_menu.has_method("return_to"):
		new_menu.return_to(menu)
	return menu
## Clears the stack and closes the ScreenUI
func terminate_stack() -> void:
	for menu: ScreenMenu in menu_stack:
		if menu.has_method("close_on_termination"):
			menu.close_on_termination()
		elif menu.has_method("close"):
			menu.close(null)
	menu_stack = []
	close()
## Returns the menu that is currently at the top of the stack
func get_active_menu() -> ScreenMenu:
	return menu_stack.back()
## Returns the menu that is second highest in the stack,
## or null if there is none
func get_previously_active_menu() -> ScreenMenu:
	if menu_stack.size() < 2:
		return null
	return menu_stack[-2]

func _ready() -> void:
	#Global.screen_ui = self
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
	if Input.is_action_just_pressed("pause") and Global.game_state == Global.GameState.PLAYING:
		if not is_open:
			add_menu(pause_menu)
			return
	
	if Input.is_action_just_pressed("pause"):
		if is_open:
			exit_menu()
