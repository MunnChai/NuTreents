class_name InputHandler
extends Node

signal device_type_changed(new_device_type: DeviceType)

enum DeviceType {
	UNKNOWN,
	KEYBOARD_MOUSE,
	CONTROLLER,
}

static var current_device_type: DeviceType = DeviceType.KEYBOARD_MOUSE

## PLAN 1
## Use Godot built-in control focus systems for navigating the UI.
## Augmenting with function calls as is necessary...
## Then, if input is not handled by UI, split behaviour based on that.
## All button inputs should be similar, no need to worry.
## Mainly camera control and aiming...
## Which should modify a Vector2i (for aim) and a Vector2 (for camera)
## So then that way when switching between input modes mouse carries over to controller...

func _input(event: InputEvent) -> void:
	var old_device_type = current_device_type
	current_device_type = get_device_type(event)
	if old_device_type != current_device_type:
		device_type_changed.emit(current_device_type)
	
	if current_device_type == DeviceType.CONTROLLER:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Checks for determing the specific event type
func is_key_event(event: InputEvent) -> bool:
	return (event is InputEventKey)
func is_mouse_event(event: InputEvent) -> bool:
	return (event is InputEventMouse or
		event is InputEventMouseMotion or
		event is InputEventMouseButton)
func is_controller_button_event(event: InputEvent) -> bool:
	return (event is InputEventJoypadButton)
func is_joystick_event(event: InputEvent) -> bool:
	return (event is InputEventJoypadMotion)

## Deduce the DeviceType based on the input event...
func get_device_type(event: InputEvent) -> DeviceType:
	if is_key_event(event) or is_mouse_event(event):
		return DeviceType.KEYBOARD_MOUSE
	if is_controller_button_event(event) or is_joystick_event(event):
		return DeviceType.CONTROLLER
	return DeviceType.UNKNOWN



## ACTUAL CURRENT INPUT LOGIC

func _process(delta: float) -> void:
	if current_device_type == DeviceType.CONTROLLER:
		#ScreenCursor.instance.global_position = get_viewport().get_camera_2d().global_position
		var cursor_move_direction = Vector2(Input.get_axis("cursor_left", "cursor_right"), Input.get_axis("cursor_up", "cursor_down")).normalized()
		ScreenCursor.instance.offset_position += cursor_move_direction * 100.0 * delta / Engine.time_scale

		Cursor.get_instance().move_to(ScreenCursor.instance.global_position)
		ScreenCursor.instance.show()

func _unhandled_input(event: InputEvent) -> void:
	# We aren't playing the game...
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (TreeManager.is_mother_dead()):
		# If mother died
		return
	
	if current_device_type == DeviceType.KEYBOARD_MOUSE:
		Cursor.get_instance().move_to(Global.terrain_map.get_local_mouse_position())
		ScreenCursor.instance.hide()
	
	if (Input.is_action_pressed("lmb")):
		if not Cursor.get_instance().can_interact():
			return
		var map_coords: Vector2i = Cursor.get_instance().iso_position
		TreeManager.add_tree(TreeManager.selected_tree_species, map_coords)
	elif (Input.is_action_just_pressed("rmb")):
		if not Cursor.get_instance().can_interact():
			return
		var map_coords: Vector2i = Cursor.get_instance().iso_position
		TreeManager.handle_right_click(map_coords)
	
	if Input.is_action_just_pressed("reset_cursor"):
		ScreenCursor.instance.offset_position = Vector2.ZERO
	
	if Input.is_action_just_pressed("menu_left"):
		TreeMenu.instance.previous_tree()
	if Input.is_action_just_pressed("menu_right"):
		TreeMenu.instance.next_tree()
