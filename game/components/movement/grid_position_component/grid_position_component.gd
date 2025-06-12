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
		return Vector2i.ZERO
	return occupied_positions[0]

## Returns the list of occupied positions of this structure...
func get_occupied_positions() -> Array[Vector2i]:
	return occupied_positions
