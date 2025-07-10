class_name VisualCursorPlantState
extends VisualCursorState

var plantable_tiles_highlight: LargeModulationHighlight
var tree_range_highlight: LargeModulationHighlight

## Get 2 new large modulation highlights, one for the plantable tiles, one for grid ranges
func enter(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	plantable_tiles_highlight = visual_cursor.get_large_highlight()

func exit(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	visual_cursor.reset_highlight_pool()


func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## Highlight the tile at iso position
	visual_cursor.highlight_tile_at(iso_position)
	
	## Highlight plantable tiles
	highlight_plantable_tiles(cursor)
	
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

func highlight_plantable_tiles(cursor: IsometricCursor) -> void:
	plantable_tiles_highlight._reset_pool()
	
	var plantable_tiles = TreeManager.get_reachable_tree_placement_positions(false)
	var to_remove: Array[Vector2i] = []
	for iso_pos: Vector2i in plantable_tiles:
		if cursor.get_hover_flag(iso_pos) != IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			to_remove.append(iso_pos)
	for iso_pos: Vector2i in to_remove:
		plantable_tiles.erase(iso_pos)
	plantable_tiles_highlight.highlight_tiles_at(plantable_tiles)
	plantable_tiles_highlight.set_color(IsometricCursorVisual.BLUE)
