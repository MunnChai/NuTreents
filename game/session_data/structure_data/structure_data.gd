class_name StructureDataResource
extends Resource

var type: Global.StructureType # What type of structure is it
var tile_type: TerrainMap.TileType # What tile is it on (important for decor)

# For sprite randomization
var flip_h: bool
var texture_region_position: Vector2

# For Tech things
var tech_slot: int

# For petrified Trees
var tree_type: Global.TreeType
