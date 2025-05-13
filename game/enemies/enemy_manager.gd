class_name EnemyManager
extends Node

## EnemyManager autoload
## Handles enemy spawning, enemy waves, etc.

static var instance

## TODO: Refactor out EnemyRegistry
## Generally make logic more easy to understand

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
 
const BASE_NUM_WAVES: int = 1
const NUM_WAVES_INCREASE_PER_DAY: float = 0.5 # casted to an int, so effectively increase by 1 every 2 days

const BASE_MIN_ENEMIES: int = 1
const BASE_MAX_ENEMIES: int = 2
const MIN_ENEMIES_INCREASE_PER_DAY: int = 1
const MAX_ENEMIES_INCREASE_PER_DAY: int = 1

var enemy_spawn_timer: float = 0
var current_wave = 0
var day_tracker = 1

var current_enemies: Array[Enemy]


func _ready() -> void:
	instance = self

func start_game():
	current_enemies.clear()
	day_tracker = 1
	enemy_spawn_timer = 0

func _input(event: InputEvent) -> void:
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	#if (Input.is_action_just_pressed("debug_button")):
		#var terrain_map = get_tree().get_first_node_in_group("terrain_map")
		#var map_coord = terrain_map.local_to_map(terrain_map.get_local_mouse_position()) # one HELL of a line
		#spawn_enemy(EnemyType.SPEEDLE, map_coord)

func _process(delta: float) -> void:
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (TreeManager.is_mother_dead()):
		# if mother died
		return
	
	var curr_time = Global.clock.get_curr_day_sec()
	if (curr_time > Global.clock.HALF_DAY_SECONDS): # NIGHT TIME
		
		#increases difficulty based on day in game
		increase_difficulty()
		
		enemy_spawn_timer -= delta
		if (enemy_spawn_timer <= 0):
			spawn_enemy_wave()
			enemy_spawn_timer = get_enemy_spawn_interval()
	else: # DAY TIME
		current_wave = 0
		if (current_enemies.size() > 0):
			kill_all_enemies()
 
# increases the severity of bug spawns based on the day
func increase_difficulty() -> void:
	var curr_day = Global.clock.get_curr_day()
	if (curr_day > day_tracker):
		day_tracker = curr_day

const CLOSEST_SPAWN_FROM_FOG_EDGE: float = 1.0
const FURTHEST_SPAWN_FROM_FOG_EDGE: float = 50.0

# Spawns enemies. returns number of enemies spawned
func spawn_enemy_wave() -> int:
	var num_enemies = randi_range(get_min_enemies_per_wave(), get_max_enemies_per_wave())
	
	# Munn: Changed a bit here, to make the lag spike less obvious
	var possible_cells = Global.fog_map.get_used_cells()
	#print("Possible: ", possible_cells.size())
	var near_cells = []
	var distance := INF
	for cell in possible_cells:
		if cell.distance_squared_to(Global.ORIGIN) < distance:
			distance = cell.distance_squared_to(Global.ORIGIN)
			near_cells.append(cell)
	#print("Near: ", near_cells.size())
	var allowed_cells = []
	for cell in near_cells:
		if cell.distance_squared_to(Global.ORIGIN) > distance + 1.0 and cell.distance_squared_to(Global.ORIGIN) < distance + 50.0:
			allowed_cells.append(cell)
	
	for i in range(0, num_enemies):
		await get_tree().create_timer(0.1).timeout # Munn: Don't spawn every enemy on one frame, causes big lag spike
		
		var rand_enemy = EnemyType.values().pick_random()
		
		var rand_pos = allowed_cells.pick_random()
		if !rand_pos: # No allowed cells
			continue
		var world_pos = Global.fog_map.map_to_local(rand_pos)
		var terrain_pos = Global.terrain_map.local_to_map(world_pos)
		
		spawn_enemy(rand_enemy, terrain_pos)
	
	return num_enemies


# Spawn an enemy of a certain type, at the given map coordinates. It will automatically begin pathfinding towards the nearest tree
func spawn_enemy(enemy_type: EnemyType, map_coords: Vector2i) -> Enemy:
	
	var enemy_node: Enemy = enemy_dict[enemy_type].instantiate()
	
	var terrain_map: TerrainMap = Global.terrain_map
	
	var world_pos: Vector2 = terrain_map.map_to_local(map_coords)
	
	enemy_node.global_position = world_pos
	enemy_node.map_position = map_coords
	enemy_node.died.connect(on_enemy_death.bind(enemy_node))
	
	var enemy_map = get_tree().get_first_node_in_group("enemy_map")
	
	enemy_map.add_child(enemy_node)
	
	current_enemies.append(enemy_node)
	
	return enemy_node

func on_enemy_death(enemy: Enemy) -> void:
	current_enemies.erase(enemy)

func kill_all_enemies():
	#print("Hello")
	for enemy: Enemy in current_enemies:
		if (!enemy):
			continue
		
		# UNCOMMENT THESE!!!!
		enemy.die()


func get_enemy_at(pos: Vector2i) -> Enemy:
	for enemy in current_enemies:
		if (!enemy):
			continue
		if (enemy.is_dead):
			continue
		if (enemy.map_position == pos):
			return enemy
	
	return null


func load_enemies_from(enemy_map: Dictionary):
	for pos in enemy_map.keys():
		var save_resource: EnemyDataResource = enemy_map[pos]
		
		var enemy: Enemy = spawn_enemy(save_resource.type, pos)
		enemy.current_health = save_resource.hp


# Functions for calculating difficulty based on the given day
func get_num_waves(day: int = day_tracker):
	return BASE_NUM_WAVES + int((day - 1) * NUM_WAVES_INCREASE_PER_DAY)

func get_max_enemies_per_wave(day: int = day_tracker) -> int:
	return BASE_MAX_ENEMIES + (day - 1) * MAX_ENEMIES_INCREASE_PER_DAY

func get_min_enemies_per_wave(day: int = day_tracker) -> int:
	return BASE_MIN_ENEMIES + (day - 1) * MIN_ENEMIES_INCREASE_PER_DAY

func get_enemy_spawn_interval(day: int = day_tracker):
	return Global.clock.HALF_DAY_SECONDS / get_num_waves(day)
