extends Node

const MAP_SIZE: Vector2i = Vector2i(1, 1) * 40

var structure_map: BuildingMap
var terrain_map: TerrainMap
var clock: Clock

func _ready() -> void:
	structure_map = get_tree().get_first_node_in_group("structure_map")
	terrain_map = get_tree().get_first_node_in_group("terrain_map")
	clock = get_tree().get_first_node_in_group("clock")
