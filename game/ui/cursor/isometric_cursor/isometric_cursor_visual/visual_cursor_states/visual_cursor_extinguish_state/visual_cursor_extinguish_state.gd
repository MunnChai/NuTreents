class_name VisualCursorExtinguishState
extends VisualCursorState

func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## Highlight the tile at iso position
	visual_cursor.highlight_tile_at(iso_position)
	
	visual_cursor.enable()
	visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
	visual_cursor.set_arrow_visible(true)
	visual_cursor.set_arrow_bobbing(true)
