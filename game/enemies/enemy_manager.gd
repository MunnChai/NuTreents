extends Node

const SILK_SPITTER: PackedScene = preload("res://enemies/silk_spitter/silk_spitter.tscn")
const SPEEDLE: PackedScene = preload("res://enemies/speedle/speedle.tscn")

enum EnemyType {
	SPEEDLE,
	SILK_SPITTER,
}

var enemy_dict: Dictionary [EnemyType, PackedScene] = {
	EnemyType.SPEEDLE: SPEEDLE,
	EnemyType.SILK_SPITTER: SILK_SPITTER
}
 






func _ready() -> void:
	#spawn_enemy(EnemyType.SPEEDLE, Constants.MAP_SIZE / 2)
	pass

func _input(event: InputEvent) -> void:
	
	if (Input.is_action_just_pressed("debug_button")):
		var terrain_map = get_tree().get_first_node_in_group("terrain_map")
		var map_coord = terrain_map.local_to_map(terrain_map.get_local_mouse_position()) # one HELL of a line
		spawn_enemy(EnemyType.SPEEDLE, map_coord)

# Spawns enemies. returns number of enemies spawned
func spawn_enemies() -> int:
	return 0

# Spawn an enemy of a certain type, at the given map coordinates. It will automatically begin pathfinding towards the nearest tree
func spawn_enemy(enemy_type: EnemyType, map_coords: Vector2i) -> void:
	
	var enemy_node: Enemy = enemy_dict[enemy_type].instantiate()
	
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	
	var world_pos: Vector2 = terrain_map.map_to_local(map_coords)
	
	enemy_node.global_position = world_pos
	enemy_node.map_position = map_coords
	
	var enemy_map = get_tree().get_first_node_in_group("enemy_map")
	
	enemy_map.add_child(enemy_node)
