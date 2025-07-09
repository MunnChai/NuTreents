class_name VisualCursorDestroyState
extends VisualCursorState

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
		IsometricCursor.HoverFlag.TOO_FAR_AWAY, IsometricCursor.HoverFlag.OBSCURED, IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			visual_cursor.enable()
			visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
			visual_cursor.set_arrow_visible(false)
			visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.NOT_FERTILE: 
			if terrain_map.is_concrete(iso_position):
				visual_cursor.enable()
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_arrow_visible(true)
				visual_cursor.set_arrow_bobbing(true)
				match terrain_map.get_tile_biome(iso_position):
					TerrainMap.TileType.CITY:
						if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_CITY_TILE):
							visual_cursor.set_arrow_bobbing(false)
					TerrainMap.TileType.ROAD:
						if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_ROAD_TILE):
							visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OCCUPIED:
			visual_cursor.enable()
			visual_cursor.set_arrow_visible(true)
			if TreeManager.is_twee(iso_position): # can always destroy tree
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_arrow_bobbing(true)
			else:
				visual_cursor.enable()
				var building_node = structure_map.get_building_node(iso_position)
				var destructable: DestructableComponent = Components.get_component(building_node, DestructableComponent)
				if not destructable: # Non destructible obstructive entity 
					visual_cursor.enable()
					visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
					visual_cursor.set_arrow_visible(false)
					visual_cursor.set_arrow_bobbing(false)
				else: # Destructible entity, check for nutreent cost
					if TreeManager.enough_n(destructable.get_cost()):
						visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
						visual_cursor.set_arrow_visible(true)
						visual_cursor.set_arrow_bobbing(true)
					else:
						visual_cursor.set_highlight_modulate(IsometricCursorVisual.YELLOW)
						visual_cursor.set_arrow_visible(true)
						visual_cursor.set_arrow_bobbing(false)
		_:
			pass ## How did we get here?
