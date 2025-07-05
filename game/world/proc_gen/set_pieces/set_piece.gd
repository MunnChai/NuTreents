class_name SetPiece
extends Node2D

## A SetPiece defines a pre-designed arrangement of tiles and structures
## that can be placed into the world by the TerrainMap.
## It requires two children:
## 1. A TileMapLayer node named "TileMapLayer" to define the tiles.
##    - Each tile MUST have custom data "biome" set to a TerrainMap.TileType enum value.
## 2. A Node2D named "Structures" to act as a container for any structure scenes.

## If this set piece is not a tree unlock, then default to Mother Tree
@export var biome: TerrainMap.Biome
@export var tree_type: Global.TreeType = Global.TreeType.MOTHER_TREE

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var structures: Node2D = $Structures

## Gathers all tile data from the child TileMapLayer.
## Returns a dictionary mapping the local grid position of each tile to its TileType.
## It will print an error if a tile is missing its required custom data.
func get_tiles() -> Dictionary[Vector2i, TerrainMap.TileType]:
	var dict: Dictionary[Vector2i, TerrainMap.TileType] = {}
	
	# Iterate over all used cells in the set piece's tilemap layer.
	for pos: Vector2i in tile_map_layer.get_used_cells():
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(pos)
		
		# --- Robustness Check ---
		# Ensure the tile has data and the required custom data layer.
		if not tile_data:
			printerr("SetPiece Error: No TileData found at ", pos, " in '", self.scene_file_path, "'. Skipping tile.")
			continue
		
		if not tile_data.has_custom_data("biome"):
			printerr("SetPiece Error: Tile at ", pos, " is missing 'biome' custom data in '", self.scene_file_path, "'. Skipping tile.")
			continue
		# --- End of Check ---
			
		var type: TerrainMap.TileType = tile_data.get_custom_data("biome")
		
		dict[pos] = type
	
	return dict

func get_tile_info() -> Dictionary[Vector2i, Dictionary]:
	var dict: Dictionary[Vector2i, Dictionary] = {}
	
	for pos: Vector2i in tile_map_layer.get_used_cells():
		var tile_data: TileData = tile_map_layer.get_cell_tile_data(pos)
		var tile_atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(pos)
		var alternative_id: int = tile_map_layer.get_cell_alternative_tile(pos)
		
		var info := {
			"atlas_coords": tile_atlas_coords,
			"alternative_id": alternative_id,
		}
		
		dict[pos] = info
	
	return dict

## Gathers all structure nodes from the child "Structures" node.
## Returns a dictionary mapping the local grid position of each structure to its node.
func get_structures() -> Dictionary[Vector2i, Node2D]:
	var dict: Dictionary[Vector2i, Node2D] = {}
	
	# Iterate over all child nodes within the "Structures" container.
	for child: Node2D in structures.get_children():
		# Convert the structure's local pixel position to a grid coordinate.
		var grid_pos: Vector2i = tile_map_layer.local_to_map(child.position)
		
		dict[grid_pos] = child
	
	return dict
