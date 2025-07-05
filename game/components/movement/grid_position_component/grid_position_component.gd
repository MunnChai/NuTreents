class_name GridPositionComponent
extends Node2D

var occupied_positions: Array

## Moves all occupied positions by given vector
func move(movement: Vector2i) -> void:
	occupied_positions = occupied_positions.map(
		func(occupied_position: Vector2i) -> Vector2i:
			return occupied_position + movement
	)

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

## Returns the first position of this structure...
func get_pos() -> Vector2i:
	if occupied_positions.is_empty():
		printerr("Error! Getting position of structure with no positions.")
		print_stack()
		return Vector2i.ZERO
	return occupied_positions[0]

## Returns the list of occupied positions of this structure...
func get_occupied_positions() -> Array:
	return occupied_positions

## Returns the average position of this structure
func get_average_pos() -> Vector2:
	var n := 0
	var pos := Vector2.ZERO
	
	for p: Vector2i in get_occupied_positions():
		n += 1
		pos += Vector2(p)
	
	if n <= 0:
		return Vector2.ZERO
	return pos / n
