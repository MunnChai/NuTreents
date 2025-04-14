extends Cursor

var is_visible: bool = true

func on_just_moved(old_pos: Vector2i, new_pos: Vector2i) -> void:
	if (!is_visible):
		return
	
	#update_adjacent_tile_transparencies()
	
	$InfoBoxDetector.detect(iso_position)

func _process(delta: float) -> void:
	if (!is_visible):
		#disable()
		return
	
	global_position = Global.terrain_map.map_to_local(iso_position)
	#wooden_arrow.set_cursor_position(global_position)
	
	#_update_visuals()
