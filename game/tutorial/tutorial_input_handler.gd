extends InputHandler

var is_enabled: bool = false


func _unhandled_input(event: InputEvent) -> void:
	# We aren't playing the game...
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (TreeManager.is_mother_dead()):
		# If mother died
		return
	
	if current_device_type == DeviceType.KEYBOARD_MOUSE:
		Cursor.get_instance().move_to(Global.terrain_map.get_local_mouse_position())
	
	if (Input.is_action_pressed("lmb")):
		if not Cursor.get_instance().can_interact():
			return
		var map_coords: Vector2i = Cursor.get_instance().iso_position
		TreeManager.place_tree(TreeManager.selected_tree_species, map_coords)
	elif (Input.is_action_just_pressed("rmb")):
		if not Cursor.get_instance().can_interact():
			return
		var map_coords: Vector2i = Cursor.get_instance().iso_position
		TreeManager.handle_right_click(map_coords)
