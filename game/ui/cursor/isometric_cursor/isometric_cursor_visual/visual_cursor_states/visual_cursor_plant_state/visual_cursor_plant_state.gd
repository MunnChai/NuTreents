class_name VisualCursorPlantState
extends VisualCursorState

func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## Highlight the tile at iso position
	visual_cursor.highlight_tile_at(iso_position)
	
	var flag := cursor.get_hover_flag()
	match flag:
		IsometricCursor.HoverFlag.VOID:
			visual_cursor.disable()
		IsometricCursor.HoverFlag.TOO_FAR_AWAY, IsometricCursor.HoverFlag.OBSCURED, \
		IsometricCursor.HoverFlag.OCCUPIED, IsometricCursor.HoverFlag.NOT_FERTILE:
			visual_cursor.enable()
			visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
			visual_cursor.set_arrow_visible(false)
			visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			visual_cursor.enable()
			visual_cursor.set_arrow_visible(true)
			if _can_plant_on_tile(iso_position) and _has_enough_n_to_plant():
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_arrow_bobbing(true)
			else:
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.YELLOW)
				visual_cursor.set_arrow_bobbing(false)
		_:
			pass ## How did we get here?
