extends Node

const MAP_SIZE: Vector2i = Vector2i(1, 1) * 40
const ORIGIN: Vector2i = MAP_SIZE / 2

var structure_map: BuildingMap
var terrain_map: TerrainMap

func _ready() -> void:
	structure_map = get_tree().get_first_node_in_group("structure_map")
	terrain_map = get_tree().get_first_node_in_group("terrain_map")
