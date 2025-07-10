class_name LargeModulationHighlight
extends Node2D

## LARGE MODULATION HIGHLIGHT
## The coloured modulation tile below the selected area
## Now with support for multi-tile structures

const MODULATION_HIGHLIGHT = preload("modulation_highlight.tscn")

@onready var canvas_group = $CanvasGroup

#region MODULATION POOL

## A pool of the current individual tile modulation highlights
var highlight_pool: Array[Node2D] = []
var next_available := 0 ## The next index of a tile that is not currently used
func _reset_pool():
	for highlight: Node2D in highlight_pool:
		highlight.hide()
	next_available = 0
## Get the next available unused modulation tile
## If none remain, instantiate a new one!
func _get_next_highlight() -> Node2D:
	var get_index = next_available
	next_available += 1
	
	if highlight_pool.size() <= get_index:
		## Don't have another one...
		## Create one!
		var new_highlight = MODULATION_HIGHLIGHT.instantiate()
		canvas_group.add_child(new_highlight)
		highlight_pool.append(new_highlight)
	
	var highlight = highlight_pool[get_index]
	highlight.show()
	return highlight

#endregion

#region HIGHLIGHT SETUP FOR POSITION

## Highlights the tile at the given isometric position
func highlight_tile_at(iso_position: Vector2i) -> void:
	_reset_pool()
	var building: Node2D = Global.structure_map.get_building_node(iso_position)
	
	## BUILDING:
	if building != null:
		var position_component: GridPositionComponent = Components.get_component(building, GridPositionComponent)
		if position_component:
			_highlight_grid_position_component(position_component)
		else: ## Huh.
			_highlight_empty_tile_at(iso_position)
	## TILE:
	else:
		_highlight_empty_tile_at(iso_position)
	
	# Munn: Updating screen space outline to match camera zoom
	canvas_group.material.set_shader_parameter("camera_zoom", Global.camera.zoom)

## Highlights the given tiles
func highlight_tiles_at(iso_positions: Array[Vector2i]) -> void:
	for iso_position: Vector2i in iso_positions:
		var highlight = _get_next_highlight()
		highlight.global_position = Global.structure_map.map_to_local(iso_position)

## Highlight only the one tile at the iso position
func _highlight_empty_tile_at(iso_position: Vector2i) -> void:
	var highlight = _get_next_highlight()
	highlight.global_position = Global.structure_map.map_to_local(iso_position)

## Highlight all tiles occupied by a GridPositionComponent
func _highlight_grid_position_component(grid_pos: GridPositionComponent) -> void:
	var positions := grid_pos.get_occupied_positions()
	for iso_position: Vector2i in positions:
		var highlight = _get_next_highlight()
		highlight.global_position = Global.structure_map.map_to_local(iso_position)

#endregion

#region COLOR

## Set the canvas group color
func set_color(color: Color) -> void:
	canvas_group.modulate = color

#endregion

#region ENABLE/DISABLE

func enable() -> void:
	visible = true

func disable() -> void:
	visible = false
