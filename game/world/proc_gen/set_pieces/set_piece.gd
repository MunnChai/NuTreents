class_name SetPiece
extends Node2D

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var structures: Node2D = $Structures

func get_tiles() -> Dictionary[Vector2i, TerrainMap.TileType]:
	var dict: Dictionary[Vector2i, TerrainMap.TileType] = {}
	
	for pos: Vector2i in tile_map_layer.get_used_cells():
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(pos)
		var type: TerrainMap.TileType = tile_data.get_custom_data("biome")
		
		dict[pos] = type
	
	return dict

func get_tile_atlases() -> Dictionary[Vector2i, Vector2i]:
	var dict: Dictionary[Vector2i, Vector2i] = {}
	
	for pos: Vector2i in tile_map_layer.get_used_cells():
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(pos)
		var tile_atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(pos)
		
		dict[pos] = tile_atlas_coords
	
	return dict

func get_structures() -> Dictionary[Vector2i, Node2D]:
	var dict: Dictionary[Vector2i, Node2D] = {}
	
	for child: Node2D in structures.get_children():
		var grid_pos: Vector2i = tile_map_layer.local_to_map(child.position)
		
		dict[grid_pos] = child
	
	return dict
