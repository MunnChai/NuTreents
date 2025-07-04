class_name EnemyManager
extends Node

## EnemyManager autoload
## Handles enemy spawning, enemy waves, etc.

static var instance

## TODO: Refactor out EnemyRegistry
## Generally make logic more easy to understand

var enemy_spawn_timer: float = 0
var current_wave = 0 
 
const DAY_ONE_BUG_LIFE_DURATION: float = 20
var day_one_unique_scenario: bool = false

func _ready() -> void:
	instance = self

func start_game(): 
	enemy_spawn_timer = 0

func _input(event: InputEvent) -> void:
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	#if (Input.is_action_just_pressed("debug_button")):
		#var terrain_map = get_tree().get_first_node_in_group("terrain_map")
		#var map_coord = terrain_map.local_to_map(terrain_map.get_local_mouse_position()) # one HELL of a line
		#spawn_enemy(Global.EnemyType.SPEEDLE, map_coord)

func _process(delta: float) -> void:
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (TreeManager.is_mother_dead()):
		return
	
	var curr_time = Global.clock.get_curr_day_sec()
	if (curr_time > Global.clock.HALF_DAY_SECONDS): # NIGHT TIME 
		# Spawn enemies DAY_ONE_BUG_LIFE_DURATION seconds before night ends on day 1
		if not day_one_unique_scenario and get_curr_day() == 1:
			enemy_spawn_timer = Global.clock.HALF_DAY_SECONDS - DAY_ONE_BUG_LIFE_DURATION
			day_one_unique_scenario = true
		
		enemy_spawn_timer -= delta
		if (enemy_spawn_timer <= 0):
			spawn_enemy_wave()
			enemy_spawn_timer = get_enemy_spawn_interval()
	else: # DAY TIME
		current_wave = 0
		kill_all_enemies()
 
func get_curr_day() -> int:
	return Global.clock.get_curr_day()

const CLOSEST_SPAWN_FROM_FOG_EDGE: float = 1.0
const FURTHEST_SPAWN_FROM_FOG_EDGE: float = 50.0
# Spawns enemies. returns number of enemies spawned
func spawn_enemy_wave() -> int:
	var target_tree = find_target_tree()
	var grid_position_component: GridPositionComponent = Components.get_component(target_tree, GridPositionComponent)
	var target_pos = grid_position_component.get_occupied_positions().pick_random()
	
	# Get cells in the fog
	var possible_cells = Global.fog_map.get_used_cells()
	var near_cells = []
	var distance := INF
	for cell in possible_cells:
		if cell.distance_squared_to(target_pos) < distance:
			if Global.fog_map.is_tile_foggy(cell):
				distance = cell.distance_squared_to(target_pos)
				near_cells.append(cell)
	
	# Get cells near the target
	var allowed_cells = []
	for cell in near_cells:
		if cell.distance_squared_to(target_pos) > distance + 1.0 and cell.distance_squared_to(target_pos) < distance + 50.0:
			allowed_cells.append(cell)
	
	# Get the spawned enemies
	var points: int = get_points_per_wave()
	var enemies_to_spawn: Array[Global.EnemyType] = choose_enemies_to_spawn(points)
	
	for type in enemies_to_spawn:
		await get_tree().create_timer(0.5).timeout # Munn: Don't spawn every enemy on one frame, causes big lag spike
		
		var rand_pos = allowed_cells.pick_random()
		if !rand_pos: # No allowed cells
			continue
		var world_pos = Global.fog_map.map_to_local(rand_pos)
		var terrain_pos = Global.terrain_map.local_to_map(world_pos)
		
		var enemy = spawn_enemy(type, terrain_pos)
	
	return enemies_to_spawn.size()

func choose_enemies_to_spawn(points: int) -> Array[Global.EnemyType]:
	
	var types: Array[Global.EnemyType] = EnemyRegistry.get_spawnable_enemies_by_day(get_curr_day())
	
	# The minimum spawn cost of the array of enemies
	var min_points: int = 999999
	for type: Global.EnemyType in types:
		var stat: EnemyStatResource = EnemyRegistry.get_enemy_stat(type)
		if stat.spawn_point_cost < min_points:
			min_points = stat.spawn_point_cost
	
	var enemies_to_spawn: Array[Global.EnemyType] = []
	
	# While we still have points to spend, choose a random enemy weighted
	while points >= min_points:
		var type: Global.EnemyType = choose_enemy_weighted(types)
		var enemy_cost: int = EnemyRegistry.get_enemy_stat(type).spawn_point_cost
		
		enemies_to_spawn.append(type)
		points -= enemy_cost
	
	return enemies_to_spawn

func choose_enemy_weighted(enemy_types: Array[Global.EnemyType]) -> Global.EnemyType:
	var weight_sum: int = 0
	for enemy_type: Global.EnemyType in enemy_types:
		weight_sum += EnemyRegistry.get_enemy_stat(enemy_type).spawn_weight
	
	var rand: int = randi_range(0, weight_sum)
	
	for enemy_type in enemy_types:
		var weight = EnemyRegistry.get_enemy_stat(enemy_type).spawn_weight
		if rand < weight:
			return enemy_type
		rand -= weight
	
	# SHOULD NEVER GET HERE
	return Global.EnemyType.SPEEDLE

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
		
		var enemy_health_component: HealthComponent = Components.get_component(enemy, HealthComponent)
		enemy_health_component.set_current_health(0)

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
const NUM_WAVES_INCREASE_PER_DAY: float = 1 # casted to an int, so effectively increase by 1 every 2 days
const MAX_WAVES: int = 10

const BASE_POINTS: int = 5
const POINTS_INCREASE_PER_DAY: int = 15

# Functions for calculating difficulty based on the given day 
func get_points_per_wave(day: int = get_curr_day()) -> int:
	return (BASE_POINTS + (day - 1) * POINTS_INCREASE_PER_DAY) / get_num_waves()

func get_num_waves(day: int = get_curr_day()):
	return min(BASE_NUM_WAVES + int((day - 1) * NUM_WAVES_INCREASE_PER_DAY), MAX_WAVES)

func get_enemy_spawn_interval(day: int = get_curr_day()):
	return Global.clock.HALF_DAY_SECONDS / get_num_waves(day)
#endregion
