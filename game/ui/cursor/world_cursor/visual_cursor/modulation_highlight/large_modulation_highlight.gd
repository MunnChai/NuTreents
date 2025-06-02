class_name LargeModulationHighlight
extends Node2D

## LARGE MODULATION HIGHLIGHT
## For handling multi-tile modulation...

## ---

const MODULATION_HIGHLIGHT = preload("modulation_highlight.tscn")

@onready var canvas_group = $CanvasGroup

var highlight_pool: Array[Node2D] = []
var next_available := 0
func reset_pool():
	for highlight: Node2D in highlight_pool:
		highlight.hide()
	next_available = 0
func get_next_highlight() -> Node2D:
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

func highlight_tile_at(iso_position: Vector2i) -> void:
	reset_pool()
	var building: Structure = Global.structure_map.get_building_node(iso_position)
	
	## BUILDING:
	if building != null:
		var positions := building.get_occupied_positions()
		for position: Vector2i in positions:
			var highlight = get_next_highlight()
			highlight.global_position = Global.structure_map.map_to_local(position)
	## TILE:
	else:
		var highlight = get_next_highlight()
		highlight.global_position = Global.structure_map.map_to_local(iso_position)
		#position = Vector2.ZERO ## The cursor will be on that tile...'
	
	# Munn: Updating screen space outline to match camera zoom
	canvas_group.material.set_shader_parameter("camera_zoom", Global.camera.zoom)

func set_color(color: Color) -> void:
	#for i in range(0, next_available):
		#highlight_pool[i].modulate = color
	canvas_group.modulate = color
