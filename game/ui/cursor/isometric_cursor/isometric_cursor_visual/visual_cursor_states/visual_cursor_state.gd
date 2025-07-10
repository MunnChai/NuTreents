class_name VisualCursorState
extends Node


## Updates the visual cursor's visuals. 
## Note: This generally doesn't need to be overriden
func update(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	_update_visuals(cursor, visual_cursor)
	
	_update_arrow_position(visual_cursor, cursor.iso_position)
	_update_arrow_height(visual_cursor, cursor.iso_position)
	_update_structure_outline(cursor.iso_position)

## Default function for updating visual cursor visuals
## The main function you should be overriding
func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	print("WARNING! _update_visuals called on VisualCursorState base class or a derived class that has not overridden its _update_visuals function")

#region ENTER/EXIT

func enter(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	pass

func exit(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	pass

#endregion

#region ARROW POSITION/HEIGHT

## Default arrow position update
func _update_arrow_position(visual_cursor: IsometricCursorVisual, iso_position: Vector2i) -> void:
	var building: Node2D = Global.structure_map.get_building_node(iso_position)
	
	## BUILDING:
	if building != null and Components.has_component(building, GridPositionComponent):
		var position_component: GridPositionComponent = Components.get_component(building, GridPositionComponent)
		var positions := position_component.get_occupied_positions()
		var average_pos := Vector2.ZERO
		var sum := 0
		for pos: Vector2i in positions:
			var smooth_pos := Global.structure_map.map_to_local(pos)
			average_pos += smooth_pos
			sum += 1
		average_pos /= sum
		visual_cursor.set_arrow_position(average_pos)
	## TILE:
	else:
		visual_cursor.set_arrow_position(visual_cursor.global_position)

## Default arrow height update
func _update_arrow_height(visual_cursor: IsometricCursorVisual, iso_position: Vector2i) -> void:
	# By default, set to low
	visual_cursor.set_arrow_height(CursorWoodenArrow.ArrowHeight.LOW)
	
	# If a structure exists and has a visual arrow component, then set it
	var building_node = Global.structure_map.get_building_node(iso_position)
	if building_node != null:
		var visual_arrow_component: VisualArrowComponent = Components.get_component(building_node, VisualArrowComponent)
		if visual_arrow_component:
			visual_cursor.set_arrow_height(visual_arrow_component.get_arrow_cursor_height(), visual_arrow_component.get_custom_height())

#endregion

#region STRUCTURE OUTLINE

var previous_position: Vector2i

## SHOW/HIDE STRUCTURE OUTLINE AT POSITION
func _update_structure_outline(new_position: Vector2i) -> void:
	## REMOVE PREVIOUS
	if previous_position != new_position:
		_hide_structure_outline(previous_position)
	previous_position = new_position
	
	var structure_map = Global.structure_map
	var building_node = structure_map.get_building_node(new_position)
	
	if building_node:
		_show_structure_outline(new_position)

func _show_structure_outline(iso_position: Vector2i):
	var entity: Node2D = MapUtility.get_entity_at(iso_position)
	if entity and Components.has_component(entity, OutlineComponent):
		var outline_component = Components.get_component(entity, OutlineComponent)
		outline_component.show_outline()
		return

func _hide_structure_outline(iso_position: Vector2i):
	var entity: Node2D = MapUtility.get_entity_at(iso_position)
	if entity and Components.has_component(entity, OutlineComponent):
		var outline_component = Components.get_component(entity, OutlineComponent)
		outline_component.hide_outline()
		return

#endregion

#region VALIDATION FUNCTIONS

## Tile validation?
func _can_plant_on_tile(iso_position: Vector2i) -> bool:
	var type := TreeMenu.instance.get_currently_selected_tree_type()
	
	## TILE VALIDATION
	var structure_map := Global.structure_map
	match type:
		Global.TreeType.TECH_TREE: ## Tech Trees must be planted on Factory Remains
			if not structure_map.tile_scene_map.has(iso_position):
				return false
			elif not Components.has_component(structure_map.tile_scene_map[iso_position], FactoryRemainsBehaviourComponent):
				return false
		_: ## All other trees cannot be planted on Factory Remains
			if structure_map.tile_scene_map.has(iso_position) and Components.has_component(structure_map.tile_scene_map[iso_position], FactoryRemainsBehaviourComponent):
				return false
	
	return true

## Enough nutreents?
func _has_enough_n_to_plant() -> bool:
	var type := TreeMenu.instance.get_currently_selected_tree_type()
	var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(type)
	if tree_stat == null:
		return false
	## COST VALIDATION
	return TreeManager.enough_n(tree_stat.cost_to_purchase)

#endregion
