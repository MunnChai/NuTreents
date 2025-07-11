class_name InputHandler
extends Node

## Handles device detection and propogation of certain inputs into the game

# The @export variables are no longer needed, as we will now use the OverlayManager.
# @export var health_view_panel: Control
# @export var water_view_panel: Control

const FAST_FORWARD_SCALE = 2.5

func _input(event: InputEvent) -> void:
	_update_device_type(event)

#region ACTUAL INPUT LOGIC

func _process(delta: float) -> void:
	_update_cursor(delta)

	# --- Fast Forward Logic ---
	if Input.is_action_pressed("fast_forward"):
		Engine.time_scale = FAST_FORWARD_SCALE
	elif Input.is_action_just_released("fast_forward"):
		Engine.time_scale = 1.0

## Updates the cursor/virtual cursor POSITION based on input type...
func _update_cursor(delta: float) -> void:
	if current_device_type == DeviceType.KEYBOARD_MOUSE:
		if is_instance_valid(IsometricCursor.instance) and is_instance_valid(Global.terrain_map):
			IsometricCursor.instance.move_to(Global.terrain_map.get_local_mouse_position())
		if is_instance_valid(VirtualCursor.instance):
			VirtualCursor.instance.hide()
	
	if current_device_type == DeviceType.CONTROLLER:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var cursor_move_direction = Input.get_vector("cursor_left", "cursor_right", "cursor_up", "cursor_down")
		if is_instance_valid(VirtualCursor.instance):
			VirtualCursor.instance.offset_position += cursor_move_direction * Settings.get_setting_or_default("virtual_cursor_speed", 50.0) * TimeUtil.unscaled_delta(delta)
			VirtualCursor.instance.show()
		if is_instance_valid(IsometricCursor.instance) and is_instance_valid(VirtualCursor.instance):
			IsometricCursor.instance.move_to(VirtualCursor.instance.global_position)

func _unhandled_input(event: InputEvent) -> void:
	# Game is not in playing mode...
	if (Global.game_state != Global.GameState.PLAYING):
		return
		
	# --- View Toggle Logic (Using OverlayManager) ---
	if event.is_action_pressed("toggle_health_view"):
		_toggle_overlay(OverlayManager.OverlayType.HEALTH_OVERLAY)
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("toggle_water_view"):
		_toggle_overlay(OverlayManager.OverlayType.WATER_OVERLAY)
		get_viewport().set_input_as_handled()


	# Mother tree is dead...
	if (TreeManager.is_mother_dead()):
		return
	
	if not is_instance_valid(IsometricCursor.instance):
		return
	
	if Input.is_action_pressed("lmb"): # We want press and hold to work...
		if not IsometricCursor.instance.can_interact():
			return
		IsometricCursor.instance.try_do_primary_action()
	else:
		IsometricCursor.instance.attempted_already = false
	
	if event.is_action_pressed("rmb"): # Only deal with on click
		if not IsometricCursor.instance.can_interact():
			return
		IsometricCursor.instance.try_do_secondary_action()
	
	## Controller reset to centre of screen...
	if Input.is_action_just_pressed("reset_cursor"):
		if is_instance_valid(VirtualCursor.instance):
			VirtualCursor.instance.offset_position = Vector2.ZERO
	
	if Input.is_action_just_pressed("water_bucket"):
		if is_instance_valid(IsometricCursor.instance):
			IsometricCursor.instance.do_water_bucket_from_god()
	
	if Input.is_action_just_pressed("toggle_destroy_action"):
		if is_instance_valid(IsometricCursor.instance):
			if IsometricCursor.instance.get_current_state() == IsometricCursor.CursorState.DESTROY:
				IsometricCursor.instance.return_to_default_state()
			else:
				IsometricCursor.instance.enter_state(IsometricCursor.CursorState.DESTROY)
	
	## Handle num keys
	if event is InputEventKey and event.is_pressed():
		var unicode = event.unicode
		if (unicode >= 48 and unicode <= 57): # 0-9
			var index = unicode - 49
			if unicode == 48:
				index = 9
			
			var tree_type: Global.TreeType = TreeMenu.instance.get_tree_type_at(index)
			TreeMenu.instance.set_currently_selected_tree_type(tree_type)
	

# This new helper function contains the logic for toggling overlays.
func _toggle_overlay(overlay_type: OverlayManager.OverlayType) -> void:
	if not is_instance_valid(OverlayManager.instance):
		return
		
	var om = OverlayManager.instance
	
	# If the overlay we want to toggle is already the current one, hide it.
	if om.current_overlay == om.overlays[overlay_type]:
		om.hide_overlay()
	# Otherwise, show the new overlay (which will automatically hide any other one).
	else:
		om.show_overlay(overlay_type)

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

#endreg
