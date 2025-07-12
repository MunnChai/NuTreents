class_name VisualCursorPlantState
extends VisualCursorState

var plantable_tiles_highlight: LargeModulationHighlight
var tree_range_highlight: LargeModulationHighlight

## Get 2 new large modulation highlights, one for the plantable tiles, one for grid ranges
func enter(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	plantable_tiles_highlight = visual_cursor.get_large_highlight()
	visual_cursor.set_hologram_visible(true)
	visual_cursor.set_hologram_offset(Vector2(0, -16))

func exit(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	visual_cursor.reset_highlight_pool()
	visual_cursor.set_hologram_visible(false)
	visual_cursor.set_hologram_offset(Vector2(0, 0))


func update(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	visual_cursor.highlight_tile_at(iso_position)
	
	highlight_plantable_tiles(cursor, visual_cursor)
	
	update_hologram_texture(visual_cursor)
	visual_cursor.set_hologram_visible(true)
	
	var flag := cursor.get_hover_flag()
	match flag:
		IsometricCursor.HoverFlag.VOID:
			visual_cursor.disable()
		IsometricCursor.HoverFlag.TOO_FAR_AWAY, IsometricCursor.HoverFlag.OBSCURED, \
		IsometricCursor.HoverFlag.NOT_FERTILE:
			visual_cursor.enable()
			visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
			visual_cursor.set_hologram_modulate(IsometricCursorVisual.RED, 0.75)
			visual_cursor.set_arrow_visible(false)
			visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OCCUPIED:
			visual_cursor.enable()
			visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
			visual_cursor.set_hologram_visible(false)
			visual_cursor.set_arrow_visible(false)
			visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			visual_cursor.enable()
			visual_cursor.set_arrow_visible(true)
			if _can_plant_on_tile(iso_position) and _has_enough_n_to_plant():
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_hologram_modulate(IsometricCursorVisual.BLUE, 0.75)
				visual_cursor.set_arrow_bobbing(true)
			else:
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.YELLOW)
				visual_cursor.set_hologram_modulate(IsometricCursorVisual.YELLOW, 0.75)
				visual_cursor.set_arrow_bobbing(false)
		_:
			pass ## How did we get here?

func highlight_plantable_tiles(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var highlight_node = visual_cursor.get_large_highlight()
	if not is_instance_valid(highlight_node): return
	
	highlight_node._reset_pool()
	
	var plantable_tiles = TreeManager.get_reachable_tree_placement_positions(false)
	var to_remove: Array[Vector2i] = []
	for iso_pos: Vector2i in plantable_tiles:
		if cursor.get_hover_flag(iso_pos) != IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			to_remove.append(iso_pos)
	for iso_pos: Vector2i in to_remove:
		plantable_tiles.erase(iso_pos)
	highlight_node.highlight_tiles_at(plantable_tiles)
	highlight_node.set_color(IsometricCursorVisual.BLUE)

func update_hologram_texture(visual_cursor: IsometricCursorVisual) -> void:
	var tree_type: Global.TreeType = TreeMenu.instance.get_currently_selected_tree_type()
	var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(tree_type)
	
	# --- BUG FIX ---
	# Added a check to ensure tree_stat is not null before trying to access its properties.
	# If it is null (meaning no tree is selected), hide the hologram.
	if tree_stat == null:
		visual_cursor.set_hologram_visible(false)
		return
	
	visual_cursor.set_hologram_texture(tree_stat.tree_icon_small)

## OVERRIDE ARROW HEIGHT
func _update_arrow_height(visual_cursor: IsometricCursorVisual, iso_position: Vector2i) -> void:
	# By default, set to low
	visual_cursor.set_arrow_height(CursorWoodenArrow.ArrowHeight.MEDIUM)
	
	# If a structure exists and has a visual arrow component, then set it
	var building_node = Global.structure_map.get_building_node(iso_position)
	if building_node != null:
		var visual_arrow_component: VisualArrowComponent = Components.get_component(building_node, VisualArrowComponent)
		if visual_arrow_component:
			visual_cursor.set_arrow_height(visual_arrow_component.get_arrow_cursor_height(), visual_arrow_component.get_custom_height())
