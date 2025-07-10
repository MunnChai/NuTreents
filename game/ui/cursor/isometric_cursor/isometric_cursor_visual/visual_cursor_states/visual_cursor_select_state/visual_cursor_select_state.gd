class_name VisualCursorSelectState
extends VisualCursorState

func enter(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	pass

func exit(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	pass

## Change visual details based on what is highlighted...
func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## Highlight the tile at iso position
	visual_cursor.highlight_tile_at(iso_position)
	
	var flag := cursor.get_hover_flag()
	
	## GENERAL HOVER CRITERIA
	match flag:
		IsometricCursor.HoverFlag.VOID:
			visual_cursor.disable()
		IsometricCursor.HoverFlag.TOO_FAR_AWAY, IsometricCursor.HoverFlag.OBSCURED, \
		IsometricCursor.HoverFlag.NOT_FERTILE, IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			visual_cursor.enable()
			visual_cursor.set_highlight_modulate(IsometricCursorVisual.YELLOW)
			visual_cursor.set_arrow_visible(false)
			visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OCCUPIED:
			# Only highlight entities that have tooltips, as those are the only ones that can be selected
			var entity: Node2D = MapUtility.get_entity_at(iso_position)
			var tooltip_component: TooltipIdentifierComponent = Components.get_component(entity, TooltipIdentifierComponent)
			if tooltip_component:
				visual_cursor.enable()
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_arrow_visible(true)
				visual_cursor.set_arrow_bobbing(true)
			else:
				visual_cursor.enable()
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.YELLOW)
				visual_cursor.set_arrow_visible(false)
				visual_cursor.set_arrow_bobbing(false)
		_:
			pass ## How did we get here?
