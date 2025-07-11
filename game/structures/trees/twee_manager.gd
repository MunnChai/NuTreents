extends Node
class_name TweeManager

signal tree_placed(new_tree: Node2D)
signal tree_removed(removed_tree: Node2D)

var fog_map: FogMap
var structure_map: BuildingMap
var terrain_map: TerrainMap

## Mapping between forest ID and forest
var forests: Dictionary[int, Forest] # {id, Forest}
## Mapping between position and forest
var forest_map: Dictionary[Vector2i, int] # {pos, id}
## Mapping between position and twees
var tree_map: Dictionary[Vector2i, Node2D]
var forest_count: int
## Mapping between position and whether it is reachable (you can place a tree there/destroy stuff), which includes tree positions
## If the position is IN THIS DICTIONARY, THEN IT IS REACHABLE. This is effectively a set, the boolean 
var reachable_tiles: Dictionary[Vector2i, int]

## Amount of nutreents the player has
var nutreents: float = 0
## Current gain rate of nutreents
var nutreents_gain: float = 0
func enough_n(cost: int) -> bool:
	return nutreents >= cost

var notification: Notification
func consume_n(cost: int) -> void:
	nutreents -= cost
	
	if is_instance_valid(NotificationLog.instance):
		if notification and not notification.is_removed:
			var previous_amount = notification.properties.get("amount", 0)
			var new_amount = previous_amount + cost
			notification.set_message(tr(&"NOTIF_SPENT").format({ "num": str(new_amount) }))
			notification.properties.set("amount", new_amount)
			notification.properties.set("time_remaining", 2.5)
		else:
			notification = Notification.new(&"cost", tr(&"NOTIF_SPENT").format({ "num": str(cost) }), { "priority": 1, "time_remaining": 3.0, "amount": cost });
			NotificationLog.instance.add_notification(notification)

#region CORE FUNCTIONALITY

const RESOURCE_TICK_RATE: float = 0.5 # Time in seconds for each tick of resources
var resource_timer: Timer

func _ready() -> void:
	resource_timer = Timer.new()
	add_child(resource_timer)
	resource_timer.one_shot = false
	resource_timer.wait_time = RESOURCE_TICK_RATE
	resource_timer.timeout.connect(get_resources)
	
	## Recalculate reachable positions upon placing or removing a tree
	tree_placed.connect(_on_tree_placed)
	tree_removed.connect(_on_tree_removed)

## Start the game with a blank slate
func start_game():
	nutreents = 25
	
	if notification:
		notification.remove()
	
	DebugConsole.register("free", func(args: PackedStringArray):
		nutreents += 1000000000
		, "Gives you a lot of nutreents")
	
	DebugConsole.register("water", func(args: PackedStringArray):
		for tree: Node2D in tree_map.values():
			var water_production: WaterProductionComponent = Components.get_component(tree, WaterProductionComponent)
			water_production.set_water_production(1000000)
		, "Gives you a near infinite amount of water")
	
	# Make sure all of these are cleared at a new game...
	forests.clear()
	forest_map.clear()
	tree_map.clear()
	reachable_tiles.clear()
	forest_count = 0
	
	# Ensure map references are correct and up to date
	fog_map = Global.fog_map
	structure_map = Global.structure_map
	terrain_map = Global.terrain_map
	
	resource_timer.start()
	
	_spawn_mother_tree()
	
	DebugConsole.register("fill_trees", func(args: PackedStringArray):
		for pos: Vector2i in terrain_map.get_used_cells():
			var default: Node2D = TreeRegistry.get_new_twee(Global.TreeType.DEFAULT_TREE)
			add_tree(default, pos)
		, "Adds a default tree to every tile on the map")

func _spawn_mother_tree() -> void:
	var mother_tree: Node2D = TreeRegistry.get_new_twee(Global.TreeType.MOTHER_TREE)
	
	var mother_tree_positions: Array[Vector2i] = [ 
		Global.ORIGIN + Vector2i.LEFT,
		Global.ORIGIN + Vector2i.LEFT + Vector2i.UP,
		Global.ORIGIN + Vector2i.UP,
		Global.ORIGIN]
	
	for position: Vector2i in mother_tree_positions:
		add_tree(mother_tree, position)
	
	var grid_position_component = Components.get_component(mother_tree, GridPositionComponent)
	grid_position_component.init_occupied_positions(mother_tree_positions)
	
	_on_tree_placed(mother_tree) # MANUAL CALL TO UPDATE REACHABLE TILES
	
	DebugConsole.register("immortal", func(args: PackedStringArray):
		var health_component: HealthComponent = Components.get_component(mother_tree, HealthComponent)
		health_component.set_max_health(100000000000)
		health_component.set_current_health(100000000000)
		, "Gives mother tree lots of health")

## Returns the twee at the given position, null if there is none
func get_twee(pos: Vector2i) -> Node2D:
	if not is_twee(pos):
		return null
	return tree_map[pos]

## Returns the forest at the given position, null if there is none
func get_forest_at(pos: Vector2i) -> Forest:
	if not is_twee(pos):
		return null
	return get_forest(forest_map[pos])

## Returns a dictionary of positions to twees
func get_tree_map() -> Dictionary[Vector2i, Node2D]:
	return tree_map

## Place the given twee at the given position
## NOTE: ONLY USE THIS FOR SINGLE TILE TWEES
func place_tree(twee: Node2D, pos: Vector2i) -> void:
	add_tree(twee, pos)

## Add the given twee to the map
func add_tree(twee: Node2D, pos: Vector2i) -> void:
	if is_twee(pos):
		return
	
	# Forest stuff...
	var f_id: int = find_forest(pos)
	forest_map[pos] = f_id
	var forest: Forest = forests[f_id]
	forest.add_tree(pos, twee)
	
	# Map...
	tree_map[pos] = twee
	
	# Structure map...
	structure_map.add_structure(pos, twee)
	
	# Signal!
	tree_placed.emit(twee)
 
## Remove the given twee at the position
## If there is no tree there, does nothing 
func remove_tree(p: Vector2i) -> void:
	if not forest_map.has(p): # No tree here. No sir.
		return
	
	# Structure map...
	structure_map.remove_structure(p)
	
	# Forest...
	var f_id = forest_map[p]
	var f: Forest = forests[f_id]
	var tree: Node2D = f.trees[p]
	
	# Signal!
	tree_removed.emit(tree)
	
	forest_map.erase(p)
	f.remove_tree(p) # Assume remove_tree will free object correctly
	forest_check(p, f_id)
	
	# Map...
	tree_map.erase(p)
	
	# Fog...
	# TODO: Put fog back?
	
	

#endregion

#region PROCESSING

func _process(delta: float) -> void:
	pass

# Occurs once per second
func get_resources(tick_rate: float = RESOURCE_TICK_RATE) -> void:
	nutreents_gain = get_nutrient_gain(tick_rate)
	nutreents += nutreents_gain * tick_rate
	update_water_maintenance(tick_rate)

func get_nutrient_gain(delta: float) -> float:
	var nutrient_sum: float = 0
	for forest_id: int in forests:
		var forest: Forest = forests[forest_id]
		nutrient_sum += forest.get_nutrient_gain()
	return nutrient_sum

func update_water_maintenance(delta: float) -> float:
	var water_gain = 0
	for forest_id: int in forests:
		var forest: Forest = forests[forest_id]
		water_gain += forest.update_water_maintenance(delta)
	return water_gain

#endregion

#region FOREST LOGIC

## finds the corresponding forest id for given p
## combine forests if neccessary
func find_forest(p: Vector2i) -> int:
	if (forest_map.has(p)):
		return forest_map[p]
	# TODO: find forest adjacent to p
	var adjacent_forests: Array[int] = []
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var neighbour = p + dir
		if (forest_map.has(neighbour)):
			if (!adjacent_forests.has(forest_map[neighbour])):
				adjacent_forests.append(forest_map[neighbour])
	
	if (adjacent_forests.is_empty()):
		# no forests near p, then p is the new forest
		forest_count += 1
		forest_map[p] = forest_count
		forests[forest_count] = Forest.new(forest_count)
		return forest_count
	
	if (adjacent_forests.size() == 1):
		return adjacent_forests[0]
	
	# TODO: if there are forest(s) near p, merge them together into new forest and assign p to that forest
	return merge_forests_brute_force(adjacent_forests)

# Returns the forest id
func merge_forests_brute_force(forests_to_merge: Array[int]) -> int:
	var forest_id: = forests_to_merge[0]
	
	# Create a new forest
	var new_forest = Forest.new(forest_id)
	
	# Remove old forests
	for id: int in forests_to_merge:
		forests.erase(id)
	
	# For every tree, if it is one of the adjacent trees' forests, add them to the new forest
	for pos: Vector2i in forest_map:
		var tree_id: int = forest_map[pos]
		
		if forests_to_merge.has(tree_id):
			var tree: Node2D = tree_map[pos]
			var tree_behaviour_component: TweeBehaviourComponent = Components.get_component(tree, TweeBehaviourComponent)
			tree_behaviour_component.forest = forest_id
			
			# Add to forest
			new_forest.trees[pos] = tree
			new_forest.add_tree_to_set(tree)
			
			# Add to forest map
			forest_map[pos] = forest_id
	
	# Add new forest to trees
	forests[forest_id] = new_forest
	
	return forest_id

## use divide-and-conquer to merge a set of Forests
## only used pseudocode before let's see if actually works
func merge_forests(list: Array[int]) -> Array[int]:
	if (list.size() == 1):
		# base case: merging is done
		return list
	var mid: int = list.size() / 2
	# both left and right should be [i]
	
	var left = merge_forests(list.slice(0, mid))
	var right = merge_forests(list.slice(mid, list.size()))
	if (left[0] == right[0]):
		return left
	
	# merge smaller set into ther larger
	if (left.size() < right.size()):
		# merge left forest into the right	
		return merge_two_forests(left, right)
	else:
		# merge right forest into the left
		return merge_two_forests(right, left)

## merge two Forests
func merge_two_forests(small: Array[int], big: Array[int]) -> Array[int]:
	if (small[0] == big[0]):
		return small
	
	var sf: Forest = forests[small[0]]
	var bf: Forest = forests[big[0]]
	
	# merge water storage
	bf.water += sf.water
	
	var trees: Dictionary[Vector2i, Node2D] = sf.trees
	var new_id = bf.id
	var old_id = sf.id
	forests.erase(old_id)
	# change forest_map (Dictionary[Vector2i, int])
	for key in trees.keys():
		forest_map[key] = new_id
	# merge small's trees into big
	bf.trees.merge(trees)
	# free small
	sf.free()
	forest_count -= 1
	return big

func get_forest(id: int) -> Forest:
	return forests[id]
	
## given a pos, check if there's a need to split the forest, split if neccessary
## id is the forest_id of the original tree
func forest_check(p: Vector2i, id: int):
	#print("forest_check called")
	# check for split
	var forest_groups: Array = check_for_split(p)
	# split if needed
	if (forest_groups.size() > 1):
		split_forests(forest_groups, id)

## check_for_split returns an array of Array[Vector2i] 
## which each array is a connected tree group
## finished (maybe we will see)
func check_for_split(p: Vector2i) -> Array:
	# find neighbouring trees
	var neighbours: Array[Vector2i] = find_neighbours(p)
	if (neighbours.is_empty()):
		# no adjacent trees yipee
		return []
	
	var groups: Array = []
	var visited: Array[Vector2i] = []
	for neigh in neighbours:
		var temp = find_group(neigh)
		if (!same_group(visited, temp)):
			groups.append(temp)
		visited.append(neigh)
	# groups should have distinct elements (haha hopefully) (it works now i think)
	return groups
	
## helper for check_for_split
func same_group(visited: Array[Vector2i], group: Array[Vector2i]) -> bool:
	for v in visited:
		if (group.has(v)):
			return true
	return false

## given an array of Array[Vector2i], assign forest to each group balabala
## i feel like it should work
func split_forests(forest_groups: Array, old_id: int):
	# need to:
	var forest_to_add = forest_groups.size()
	for i in range(forest_to_add):
		new_forest_tada(forest_groups[i], forest_count + i + 1, old_id)
	# update forest_count
	forest_count += forest_to_add
	#for f in forests.keys():
		#forests[f].print_forest()
	#print_forest_map()
	return

## new a forest with given id
func new_forest_tada(trees: Array[Vector2i], id: int, old_id: int) -> Forest:
	# remove tree from old forest
	var old_f: Forest = forests[old_id]
	
	# update forests
	var forest: Forest = Forest.new(id)
	forests[id] = forest
	for pos in trees:
		var tree = tree_map[pos]
		
		# remove these from old forest
		old_f.trees.erase(pos)
		old_f.tree_set.erase(tree)
	
		## update some info
		#if (pos == Global.ORIGIN):
			#continue
		var tree_behaviour_component: TweeBehaviourComponent = Components.get_component(tree, TweeBehaviourComponent)
		tree_behaviour_component.forest = id
		forest_map[pos] = id
		
		# add this to new forest
		forest.trees[pos] = tree
		forest.add_tree_to_set(tree)
	return forest

## returns a connected tree set
## finished i think (90% sure)
func find_group(p: Vector2i) -> Array[Vector2i]:
	var to_visit: Array[Vector2i] = [p]
	to_visit.append_array(find_neighbours(p))
	var group: Array[Vector2i] = []
	while (!to_visit.is_empty()):
		# while there are still trees connected
		var t: Vector2i = to_visit.pop_front()
		if (!group.has(t)):
			# if t is not added to group yet
			group.append(t)
			to_visit.append_array(find_neighbours(t))
	return group
	
## returns an array containing all adjacent trees of given p
func find_neighbours(p: Vector2i) -> Array[Vector2i]:
	var tree_groups: Array[Vector2i]
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var neighbour = p + dir
		if (forest_map.has(neighbour)):
			tree_groups.append(neighbour)
	return tree_groups

#endregion

#region POSITIONAL CHECKS

func is_mother_dead() -> bool:
	if not tree_map.has(Global.ORIGIN):
		return true
	
	return Components.get_component(tree_map[Global.ORIGIN], HealthComponent).is_dead

## Returns true if there is a tree at the given location
func is_twee(pos: Vector2i):
	return tree_map.has(pos)

## Returns true if there is a LARGE tree at the given location
func is_large(pos: Vector2i):
	if not is_twee(pos):
		return false
	return get_twee(pos).is_large

## Returns true if the given position is within range of the trees
func is_reachable(pos: Vector2i, include_trees: bool = false):
	return get_reachable_tree_placement_positions(include_trees).has(pos)

func get_reachable_tree_placement_positions(include_trees: bool = false) -> Array[Vector2i]:
	if include_trees:
		return reachable_tiles.keys()
	
	var allowed_positions: Array[Vector2i] = []
	
	for pos: Vector2i in reachable_tiles.keys():
		if not tree_map.has(pos):
			allowed_positions.append(pos)
	
	return allowed_positions

func _on_tree_placed(tree: Node2D) -> void:
	var grid_range_component: GridRangeComponent = Components.get_component(tree, GridRangeComponent, "GridRangeComponent")
	var grid_position_component: GridPositionComponent = Components.get_component(tree, GridPositionComponent)
	var positions: Array = grid_position_component.get_occupied_positions()
	for pos: Vector2i in positions:
		for offset: Vector2i in grid_range_component.get_tiles_in_range():
			var iso_pos: Vector2i = pos + offset
			
			if reachable_tiles.has(iso_pos):
				reachable_tiles[iso_pos] += 1
			else:
				reachable_tiles[iso_pos] = 1

func _on_tree_removed(tree: Node2D) -> void:
	var grid_range_component: GridRangeComponent = Components.get_component(tree, GridRangeComponent, "GridRangeComponent")
	var grid_position_component: GridPositionComponent = Components.get_component(tree, GridPositionComponent)
	var positions: Array = grid_position_component.get_occupied_positions()
	for pos: Vector2i in positions:
		for offset: Vector2i in grid_range_component.get_tiles_in_range():
			var iso_pos: Vector2i = pos + offset
			
			if reachable_tiles.has(iso_pos):
				reachable_tiles[iso_pos] -= 1
				
				if reachable_tiles[iso_pos] <= 0:
					reachable_tiles.erase(iso_pos)

## Recalculates the reachable_tiles map
#func _recalculate_reachable_positions() -> void:
	#reachable_tiles.clear()
	#
	#var tree_map = get_tree_map()
	#for pos in tree_map.keys():
		#var tree: Node2D = tree_map.get(pos)
		#var grid_range_component: GridRangeComponent = Components.get_component(tree, GridRangeComponent, "GridRangeComponent")
		#
		#for offset in grid_range_component.get_tiles_in_range():
			#var new_pos = pos + offset
			#if not tree_map.has(new_pos):
				#reachable_tiles[new_pos] = false
		#
		#reachable_tiles[pos] = false

#endregion
