class_name GridRangeComponent
extends Node2D

@export_enum("Diamond", "Square") var shape: String = "Diamond"
@export var range: int

func is_in_range(current_position: Vector2i, target_position: Vector2i) -> bool:
	var tiles_around = get_tiles_in_range().map(
		func(tile_offset: Vector2i):
			return current_position + tile_offset
	)
	
	return tiles_around.has(target_position)

func get_tiles_in_range() -> Array[Vector2i]:
	if shape == "Diamond":
		return get_diamond_tiles(self.range)
	else:
		return get_square_tiles()

# Recursive diamond shape
func get_diamond_tiles(range: int) -> Array[Vector2i]:
	if range < 0:
		return []
	elif range == 0:
		return [Vector2i.ZERO]
	
	var tiles = get_diamond_tiles(range - 1)
	
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.ZERO]
	
	var new_tiles: Array[Vector2i] = []
	
	for tile: Vector2i in tiles:
		for direction: Vector2i in directions:
			var new_tile = tile + direction
			
			if not new_tiles.has(new_tile):
				new_tiles.append(new_tile)
	
	return new_tiles

func get_square_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	
	for x in range(-range, range + 1):
		for y in range(-range, range + 1):
			tiles.append(Vector2i(x, y))
	
	return tiles

func increase_range(amount: int) -> void:
	range += amount
