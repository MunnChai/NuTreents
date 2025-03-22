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
 
const NUM_WAVES: int = 5
const ENEMY_SPAWN_INTERVAL: float = Global.clock.HALF_DAY_SECONDS / NUM_WAVES
var spawning_interval: float = 0
var current_wave = 0

const MIN_ENEMIES_PER_WAVE: int = 4
const MAX_ENEMIES_PER_WAVE: int = 6

var current_enemies: Array[Enemy]


func _ready() -> void:
	#spawn_enemy(EnemyType.SPEEDLE, Global.MAP_SIZE / 2)
	pass

func _input(event: InputEvent) -> void:
	pass
	if (Input.is_action_just_pressed("debug_button")):
		var terrain_map = get_tree().get_first_node_in_group("terrain_map")
		var map_coord = terrain_map.local_to_map(terrain_map.get_local_mouse_position()) # one HELL of a line
		spawn_enemy(EnemyType.SILK_SPITTER, map_coord)

func _process(delta: float) -> void:
	var curr_time = Global.clock.get_curr_day_sec()
	
	if (curr_time > Global.clock.HALF_DAY_SECONDS): # NIGHT TIME
		spawning_interval -= delta
		if (spawning_interval <= 0):
			spawn_enemies()
			spawning_interval = ENEMY_SPAWN_INTERVAL
	else: # DAY TIME
		current_wave = 0
		if (current_enemies.size() > 0):
			kill_all_enemies()
 


# Spawns enemies. returns number of enemies spawned
func spawn_enemies() -> int:
	var num_enemies = randi_range(MIN_ENEMIES_PER_WAVE, MAX_ENEMIES_PER_WAVE)
	
	for i in range(0, num_enemies):
		var rand_enemy = EnemyType.values().pick_random()
		
		var rand_pos = Global.fog_map.get_used_cells().pick_random()
		var world_pos = Global.fog_map.map_to_local(rand_pos)
		var terrain_pos = Global.terrain_map.local_to_map(world_pos)
		
		spawn_enemy(1, terrain_pos)
	
	return num_enemies

# Spawn an enemy of a certain type, at the given map coordinates. It will automatically begin pathfinding towards the nearest tree
func spawn_enemy(enemy_type: EnemyType, map_coords: Vector2i) -> void:
	
	var enemy_node: Enemy = enemy_dict[enemy_type].instantiate()
	
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	
	var world_pos: Vector2 = terrain_map.map_to_local(map_coords)
	
	enemy_node.global_position = world_pos
	enemy_node.map_position = map_coords
	
	var enemy_map = get_tree().get_first_node_in_group("enemy_map")
	
	enemy_map.add_child(enemy_node)
	
	current_enemies.append(enemy_node)


func kill_all_enemies():
	#print("Hello")
	for enemy: Enemy in current_enemies:
		enemy.die()
		current_enemies.erase(enemy)
