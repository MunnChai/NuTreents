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
 
var num_waves: int = 2
var enemy_spawn_interval: float = Global.clock.HALF_DAY_SECONDS / num_waves
var spawning_interval_tracker: float = 0
var current_wave = 0
var day_tracker = 1

var min_enemies_per_wave: int = 1
var max_enemies_per_wave: int = 2

var current_enemies: Array[Enemy]


func _ready() -> void:
	pass

func start_game():
	current_enemies.clear()
	current_wave = 0
	day_tracker = 1
	spawning_interval_tracker = 0
	num_waves = 1
	enemy_spawn_interval = Global.clock.HALF_DAY_SECONDS / num_waves

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
		
		spawning_interval_tracker -= delta
		if (spawning_interval_tracker <= 0):
			spawn_enemies()
			spawning_interval_tracker = enemy_spawn_interval
	else: # DAY TIME
		current_wave = 0
		if (current_enemies.size() > 0):
			kill_all_enemies()
 
# increases the severity of bug spawns based on the day
func increase_difficulty() -> void:
	var curr_day = Global.clock.get_curr_day()
	if (curr_day > day_tracker):
		var isOdd: int = curr_day % 2
		
		#if day is an odd day, increase waves
		if (isOdd != 0):
			num_waves *= 2
		
		#if day is an even day, increase number of enemies per wave
		else:
			if (min_enemies_per_wave * 2 >= max_enemies_per_wave):
				max_enemies_per_wave *= 2
			else:
				min_enemies_per_wave *= 2
		
		# update day tracker, don't forget silly :)
		day_tracker = curr_day

# Spawns enemies. returns number of enemies spawned
func spawn_enemies() -> int:
	var num_enemies = randi_range(min_enemies_per_wave, max_enemies_per_wave)
	
	for i in range(0, num_enemies):
		var rand_enemy = EnemyType.values().pick_random()
		
		var possible_cells = Global.fog_map.get_used_cells()
		var distance = INF
		for cell in possible_cells:
			if cell.distance_squared_to(Global.ORIGIN) < distance:
				distance = cell.distance_squared_to(Global.ORIGIN)
		
		var allowed_cells = []
		for cell in possible_cells:
			if cell.distance_squared_to(Global.ORIGIN) > distance + 1.0 and cell.distance_squared_to(Global.ORIGIN) < distance + 10.0:
				allowed_cells.append(cell)
		
		var rand_pos = allowed_cells.pick_random()
		var world_pos = Global.fog_map.map_to_local(rand_pos)
		var terrain_pos = Global.terrain_map.local_to_map(world_pos)
		
		spawn_enemy(rand_enemy, terrain_pos)
	
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
		if (!enemy):
			continue
		
		# UNCOMMENT THESE!!!!
		enemy.die()
		current_enemies.erase(enemy)


func get_enemy_at(pos: Vector2i) -> Enemy:
	for enemy in current_enemies:
		if (!enemy):
			continue
		if (enemy.is_dead):
			continue
		if (enemy.map_position == pos):
			return enemy
	
	return null
