class_name Structure
extends Node2D

## String identifier for this structure
var id: String
var occupied_positions: Array[Vector2i]

# Flag to prevent repeated removal requests
var marked_for_removal: bool = false

func _ready() -> void:
	id = "structure"

## Initalize the SINGLE isometric position of this structure...
func init_pos(p: Vector2i) -> void:
	occupied_positions = [] 
	add_occupied_pos(p)

## Add a position that this structure occupies...
func add_occupied_pos(p: Vector2i) -> void:
	if occupied_positions.has(p):
		return
	occupied_positions.append(p)

## Initialize the list of ALL OCCUPIED ISOMETRIC POSITIONS of this structure...
func init_occupied_positions(positions: Array[Vector2i]) -> void:
	for pos: Vector2i in positions:
		add_occupied_pos(pos)

## Removes self from the world
func remove():
	if marked_for_removal:
		return
	marked_for_removal = true
	
	for pos: Vector2i in get_occupied_positions():
		Global.structure_map.remove_structure(pos)

## Returns the string id of this structure...
func get_id() -> String:
	return id

## Returns the first position of this structure...
func get_pos() -> Vector2i:
	if occupied_positions.is_empty():
		printerr("Error! Getting position of structure with no positions.")
		return Vector2i.ZERO
	return occupied_positions[0]

## Returns the list of occupied positions of this structure...
func get_occupied_positions() -> Array[Vector2i]:
	return occupied_positions

## Returns the "height" that the arrow cursor should be above this structure...
## One of "low", "medium", and "high".
func get_arrow_cursor_height() -> String:
	return "low"

func apply_data_resource(save_resource: Resource):
	pass
