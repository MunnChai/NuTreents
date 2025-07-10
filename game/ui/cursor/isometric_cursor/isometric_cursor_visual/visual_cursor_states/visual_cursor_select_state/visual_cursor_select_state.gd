class_name VisualCursorSelectState
extends VisualCursorState

var selected_highlight: LargeModulationHighlight
var attack_range_highlight: LargeModulationHighlight

func _ready() -> void:
	IsometricCursor.instance.selected_entity_changed.connect(_on_selected_entity_changed)

func enter(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	selected_highlight = visual_cursor.get_large_highlight()
	attack_range_highlight = visual_cursor.get_large_highlight()

func exit(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	selected_highlight.disable()
	attack_range_highlight.disable()
	visual_cursor.reset_highlight_pool()

## Change visual details based on what is highlighted...
func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## Highlight the tile at iso position
	visual_cursor.highlight_tile_at(iso_position)
	
	_update_selected_entity(cursor, visual_cursor)
	
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

func _update_selected_entity(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var entity: Node2D = cursor.get_selected_entity()
	
	if not is_instance_valid(entity):
		selected_highlight.disable()
		attack_range_highlight.disable()
		return
	
	selected_highlight.enable()
	selected_highlight.set_color(IsometricCursorVisual.BLUE)
	var grid_pos: GridPositionComponent = Components.get_component(entity, GridPositionComponent)
	selected_highlight.highlight_tile_at(grid_pos.get_pos())
	_show_structure_outline(grid_pos.get_pos())
	
	var attack_range: GridRangeComponent = Components.get_component(entity, GridRangeComponent, "AttackRangeComponent")
	if attack_range:
		_show_attack_range_highlight(grid_pos, attack_range, visual_cursor)
	else:
		_hide_attack_range_highlight()

func _show_attack_range_highlight(grid_position: GridPositionComponent, attack_range: GridRangeComponent, visual_cursor: IsometricCursorVisual) -> void:
	attack_range_highlight.enable()
	var range_tiles = attack_range.get_tiles_in_range().map(
		func(pos: Vector2i):
			return pos + grid_position.get_pos()
	)
	attack_range_highlight.highlight_tiles_at(range_tiles)
	attack_range_highlight.set_color(IsometricCursorVisual.RED)
	#
	#for iso_pos: Vector2i in range_tiles:
		#var structure: Node2D = MapUtility.get_structure_at(iso_pos)
		#if not is_instance_valid(structure):
			#continue
		#if iso_pos == grid_position.get_pos():
			#continue
		#var tween: Tween = get_tree().create_tween()
		#tween.tween_property(structure, "modulate", Color(structure.modulate, 0.3), 0.2)

func _hide_attack_range_highlight() -> void:
	attack_range_highlight.disable()

func _on_selected_entity_changed(old_entity: Node2D, new_entity: Node2D) -> void:
	if is_instance_valid(old_entity):
		var grid_pos: GridPositionComponent = Components.get_component(old_entity, GridPositionComponent)
		_hide_structure_outline(grid_pos.get_pos())
		_hide_attack_range_highlight()
