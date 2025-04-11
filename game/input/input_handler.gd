class_name InputHandler
extends Node

func _input(event: InputEvent) -> void:
	_update_device_type(event)

#region ACTUAL INPUT LOGIC

func _process(delta: float) -> void:
	_update_cursor(delta)

## Updates the cursor/virtual cursor POSITION based on input type...
func _update_cursor(delta: float) -> void:
	if current_device_type == DeviceType.KEYBOARD_MOUSE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Cursor.instance.move_to(Global.terrain_map.get_local_mouse_position())
		VirtualCursor.instance.hide()
	
	if current_device_type == DeviceType.CONTROLLER:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var cursor_move_direction = Vector2(Input.get_axis("cursor_left", "cursor_right"), Input.get_axis("cursor_up", "cursor_down")).normalized()
		VirtualCursor.instance.offset_position += cursor_move_direction * Settings.get_setting_or_default("virtual_cursor_speed", 50.0) * TimeUtil.unscaled_delta(delta)
		Cursor.instance.move_to(VirtualCursor.instance.global_position)
		VirtualCursor.instance.show()

func _unhandled_input(event: InputEvent) -> void:
	# Game is not in playing mode...
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	# Mother tree is dead...
	if (TreeManager.is_mother_dead()):
		return
	
	if (Input.is_action_pressed("lmb")): # We want press and hold to work...
		if not Cursor.instance.can_interact():
			return
		Cursor.instance.do_primary_action()
	else:
		Cursor.instance.attempted_already = false
	
	if (Input.is_action_just_pressed("rmb")): # Only deal with on click
		if not Cursor.instance.can_interact():
			return
		Cursor.instance.do_secondary_action()
	
	## Controller reset to centre of screen...
	if Input.is_action_just_pressed("reset_cursor"):
		VirtualCursor.instance.offset_position = Vector2.ZERO
	
	## Controller shift left/right in menu...
	if Input.is_action_just_pressed("menu_left"):
		TreeMenu.instance.previous_tree()
	if Input.is_action_just_pressed("menu_right"):
		TreeMenu.instance.next_tree()

#endregion

#region DEVICE TYPE

signal device_type_changed(new_device_type: DeviceType)

enum DeviceType {
	UNKNOWN,
	KEYBOARD_MOUSE,
	CONTROLLER,
}

static var current_device_type: DeviceType = DeviceType.KEYBOARD_MOUSE
static func is_using_controller() -> bool:
	return current_device_type == DeviceType.CONTROLLER
static func is_using_keyboard() -> bool:
	return current_device_type == DeviceType.KEYBOARD_MOUSE

func _update_device_type(event: InputEvent) -> void:
	var old_device_type = current_device_type
	current_device_type = get_device_type(event)
	if old_device_type != current_device_type:
		device_type_changed.emit(current_device_type)

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

#endregion
