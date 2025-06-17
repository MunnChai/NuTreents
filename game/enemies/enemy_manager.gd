class_name EnemyManager
extends Node

## EnemyManager autoload
## Handles enemy spawning, enemy waves, etc.

static var instance

## TODO: Refactor out EnemyRegistry
## Generally make logic more easy to understand

var enemy_spawn_timer: float = 0
var current_wave = 0
var day_tracker = 1

func _ready() -> void:
	instance = self

func start_game():
	day_tracker = 1
	enemy_spawn_timer = 0

func _input(event: InputEvent) -> void:
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (Input.is_action_just_pressed("debug_button")):
		var terrain_map = get_tree().get_first_node_in_group("terrain_map")
		var map_coord = terrain_map.local_to_map(terrain_map.get_local_mouse_position()) # one HELL of a line
		spawn_enemy(Global.EnemyType.SPEEDLE, map_coord)

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
		#kill_all_enemies()
 
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
	
	var target_tree = find_target_tree()
	var grid_position_component: GridPositionComponent = Components.get_component(target_tree, GridPositionComponent)
	var target_pos = grid_position_component.get_occupied_positions().pick_random()
	
	# Munn: Changed a bit here, to make the lag spike less obvious
	var possible_cells = Global.fog_map.get_used_cells()
	#print("Possible: ", possible_cells.size())
	var near_cells = []
	var distance := INF
	for cell in possible_cells:
		if cell.distance_squared_to(target_pos) < distance:
			if Global.fog_map.is_tile_foggy(cell):
				distance = cell.distance_squared_to(target_pos)
				near_cells.append(cell)
	#print("Near: ", near_cells.size())
	var allowed_cells = []
	for cell in near_cells:
		if cell.distance_squared_to(target_pos) > distance + 1.0 and cell.distance_squared_to(target_pos) < distance + 50.0:
			allowed_cells.append(cell)
	
	for i in range(0, num_enemies):
		await get_tree().create_timer(0.1).timeout # Munn: Don't spawn every enemy on one frame, causes big lag spike
		
		var rand_enemy = Global.EnemyType.values().pick_random()
		
		var rand_pos = allowed_cells.pick_random()
		if !rand_pos: # No allowed cells
			continue
		var world_pos = Global.fog_map.map_to_local(rand_pos)
		var terrain_pos = Global.terrain_map.local_to_map(world_pos)
		
		var enemy = spawn_enemy(rand_enemy, terrain_pos)
	
	return num_enemies

# Searches forest for high priority trees
# Priority: Tech Tree > Water Tree > Mother Tree > Any other tree
func find_target_tree(trees_to_avoid: Array[Node2D] = []) -> Node2D:
	var tree_map = TreeManager.get_tree_map()
	
	# Find types of trees
	var tech_trees: Array = []
	var water_trees: Array = []
	var mother_tree: Node2D = null
	for twee: Node2D in tree_map.values():
		# Don't count ignored trees
		if trees_to_avoid.has(twee):
			continue
		
		var tree_stat_component: TweeStatComponent = Components.get_component(twee, TweeStatComponent)
		
		if tree_stat_component.type == Global.TreeType.TECH_TREE:
			tech_trees.append(twee)
		if tree_stat_component.type == Global.TreeType.WATER_TREE:
			water_trees.append(twee)
		if tree_stat_component.type == Global.TreeType.MOTHER_TREE:
			mother_tree = twee
	
	# Sort tree arrays by distance to nearest tree to avoid (furthest -> closest)
	# Munn: This is to spawn waves further from each other, so they don't all end up attacking the same tree
	
	# If any prioritized trees were found, target them!
	if not tech_trees.is_empty():
		return tech_trees.pick_random()
	elif not water_trees.is_empty():
		return water_trees.pick_random()
	elif mother_tree != null: # Munn: This should always happen?? 
		return mother_tree
	
	return tree_map.pick_random()

# Spawn an enemy of a certain type, at the given map coordinates. It will automatically begin pathfinding towards the nearest tree
func spawn_enemy(enemy_type: Global.EnemyType, map_coords: Vector2i) -> Node2D:
	
	var enemy_node: Node2D = EnemyRegistry.get_new_enemy(enemy_type)
	
	var terrain_map: TerrainMap = Global.terrain_map
	
	var world_pos: Vector2 = terrain_map.map_to_local(map_coords)
	
	var enemy_map = get_tree().get_first_node_in_group("enemy_map")
	enemy_map.add_child(enemy_node)
	
	enemy_node.global_position = world_pos
	var position_component: GridPositionComponent = Components.get_component(enemy_node, GridPositionComponent)
	position_component.init_pos(map_coords)
	
	return enemy_node

func kill_all_enemies():
	for enemy: Node2D in get_enemies():
		if (!enemy):
			continue
		
		enemy.die()

func get_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")

func get_enemy_at(pos: Vector2i):
	for enemy in get_enemies():
		if not enemy:
			continue
		
		var health_component: HealthComponent = Components.get_component(enemy, HealthComponent)
		if health_component.is_dead:
			continue
		
		var grid_position_component: GridPositionComponent = Components.get_component(enemy, GridPositionComponent)
		if grid_position_component.get_pos() == pos:
			return enemy
	
	return null


#region SaveAndLoad
func load_enemies_from(enemy_map: Dictionary):
	for pos in enemy_map.keys():
		var save_resource: EnemyDataResource = enemy_map[pos]
		
		var enemy: Node2D = spawn_enemy(save_resource.type, pos)
		var health_component = Components.get_component(enemy, HealthComponent)
		health_component.current_health = save_resource.hp
#endregion

#region DifficultyFunctions

const BASE_NUM_WAVES: int = 1
const NUM_WAVES_INCREASE_PER_DAY: float = 0.5 # casted to an int, so effectively increase by 1 every 2 days

const BASE_MIN_ENEMIES: int = 1
const BASE_MAX_ENEMIES: int = 2
const MIN_ENEMIES_INCREASE_PER_DAY: int = 1
const MAX_ENEMIES_INCREASE_PER_DAY: int = 1

# Functions for calculating difficulty based on the given day
func get_num_waves(day: int = day_tracker):
	return BASE_NUM_WAVES + int((day - 1) * NUM_WAVES_INCREASE_PER_DAY)

func get_max_enemies_per_wave(day: int = day_tracker) -> int:
	return BASE_MAX_ENEMIES + (day - 1) * MAX_ENEMIES_INCREASE_PER_DAY

func get_min_enemies_per_wave(day: int = day_tracker) -> int:
	return BASE_MIN_ENEMIES + (day - 1) * MIN_ENEMIES_INCREASE_PER_DAY

func get_enemy_spawn_interval(day: int = day_tracker):
	return Global.clock.HALF_DAY_SECONDS / get_num_waves(day)
#endregion
