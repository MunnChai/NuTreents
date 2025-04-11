extends Node
class_name tree_manager

var fog_map: FogMap
var structure_map: BuildingMap
var terrain_map: TerrainMap

const MOTHER_TREE = preload("res://trees/scenes/MotherTree.tscn")
const DEFAULT_TREE = preload("res://trees/scenes/DefaultTree.tscn")
const GUN_TREE = preload("res://trees/scenes/GunTree.tscn")
const WATER_TREE = preload("res://trees/scenes/WaterTree.tscn")
const TECH_TREE = preload("res://trees/scenes/TechTree.tscn")
const EXPLORER_TREE = preload("res://trees/scenes/ExplorerTree.tscn")
const TALL_TREE = preload("res://trees/scenes/TallTree.tscn")

enum TreeType {
	MOTHER_TREE = 0,
	DEFAULT_TREE = MOTHER_TREE + 1,
	GUN_TREE = DEFAULT_TREE + 1,
	WATER_TREE = GUN_TREE + 1,
	TECH_TREE = WATER_TREE + 1,
	EXPLORER_TREE = TECH_TREE + 1,
	TALL_TREE = EXPLORER_TREE + 1,
}

const TREE_DICT: Dictionary[int, PackedScene] = {
	TreeType.MOTHER_TREE: MOTHER_TREE,
	TreeType.DEFAULT_TREE: DEFAULT_TREE,
	TreeType.GUN_TREE: GUN_TREE,
	TreeType.WATER_TREE: WATER_TREE,
	TreeType.TECH_TREE: TECH_TREE,
	TreeType.EXPLORER_TREE: EXPLORER_TREE,
	TreeType.TALL_TREE: TALL_TREE
}


# stores all trees
var forests: Dictionary[int, Forest] # {id, Forest}
var forest_map: Dictionary[Vector2i, int] # {pos, id}
var tree_map: Dictionary[Vector2i, Twee]
var res: Vector3 # Vec3(N, water, sun)
var gain: Vector3
var forest_count: int

# currently selected tree from ui
var selected_tree_species: int = 1


# Used in the tutorial
signal tree_placed


func _ready():
	pass

func start_game():
	res = Vector3(1000, 0, 0)
	gain = Vector3(0, 0, 0)
	forest_count = 0
	#test()
	#res += Vector3(10000000, 0, 100)
	
	forests.clear()
	forest_map.clear()
	tree_map.clear()
	
	fog_map = get_tree().get_nodes_in_group("fog_map")[0]
	structure_map = get_tree().get_nodes_in_group("structure_map")[0]
	terrain_map = get_tree().get_nodes_in_group("terrain_map")[0]
	
	EnemyManager.start_game()
	
	await get_tree().process_frame
	
	call_deferred("add_tree", 0, Global.MAP_SIZE / 2, false)

	print("Yes!!")

func _process(delta):
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if Input.is_action_just_released("lmb"):
		placed = false
	
	# Munn: don't really need to pass in delta, but could be useful in the future
	gain.x = get_nutrient_gain(delta)
	gain.y = update_water_maintenance(delta)
	gain.z = 0
	
	res += gain * delta
	res = res.clamp(Vector3(0,0,0), Vector3(INF,INF,INF)) # Resources cannot go below 0

func test():
	# testing
	var button = Button.new()
	button.text = "Update Resource (Forest and TreeManager testing)"
	button.pressed.connect(_button_pressed)
	button.set_position(Vector2i(0,-100))
	add_child(button)
	print(remove_tree(Vector2i(1,0)))
	print(add_tree(1, Vector2i(1,0)))
	forests[1].print_forest()
	print(forest_map)

func _button_pressed():
	update(1.0)
	var f: Forest = forests[1]
	f.print_forest()
	print(forest_map)
	
## to be called each round, update everything?
func update(delta: float):
	if Input.is_action_just_released("lmb"):
		placed = false
	if (tree_map[Global.ORIGIN].died):
		# if mother tree is dead
		return
	gain = Vector3()
	# iterate all trees, get their generated res and remove dead trees
	for key in forests.keys():
		var f: Forest = forests[key]
		gain += f.update(delta)
		
		if (f.empty):
			remove_forest(key)  
	
	res += gain * delta
	res.y = max(0, res.y)

func get_nutrient_gain(delta: float) -> float:
	var nutrient_sum: float = 0
	
	for forest_id: int in forests:
		var forest: Forest = forests[forest_id]
		
		nutrient_sum += forest.get_nutrient_gain(delta)
	
	return nutrient_sum

func update_water_maintenance(delta: float) -> float:
	var water_gain = 0
	
	for forest_id: int in forests:
		var forest: Forest = forests[forest_id]
		
		water_gain += forest.update_water_maintenance(delta)
	
	return water_gain


func get_new_tree_of_type(type: int) -> Twee:
	return TREE_DICT[type].instantiate()
func get_new_tree_of_currently_selected_type() -> Twee:
	return get_new_tree_of_type(TreeManager.selected_tree_species)

var placed = false
## add tree with given type at p
# TODO type: will add more types later, codes only use DefaultTree for now
## return: 0 -> successful, 1 -> unavailable space, 2-> insufficient resources
func add_tree(type: int, p: Vector2i, enforce_reachable: bool = true) -> int:
	var tree: Twee
	tree = get_new_tree_of_type(type)
	
	if (terrain_map.is_void(p)):
		return -1
	
	if (forest_map.has(p)):
		if Input.is_action_just_pressed("lmb") and !placed:
			placed = true
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Occupied!", structure_map.map_to_local(p), Color("ffb561"))
		return 1
	if enforce_reachable and not is_reachable(p):
		if Input.is_action_just_pressed("lmb") and !placed:
			placed = true
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Too far away!", structure_map.map_to_local(p))
		return 4
	if not terrain_map.is_fertile(p):
		if Input.is_action_just_pressed("lmb") and !placed:
			placed = true
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Ground not fertile!", structure_map.map_to_local(p))
		return 3 
	if (!enough_n(tree.tree_stat.cost_to_purchase)):
		if Input.is_action_just_pressed("lmb") and !placed:
			placed = true
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Not enough nutreents!", structure_map.map_to_local(p))
		return 2
	if (type == TreeType.TECH_TREE):
		var can_place = true
		if (!structure_map.tile_scene_map.has(p)):
			can_place = false
		else:
			var structure: Structure = structure_map.tile_scene_map[p]
			if (not structure is FactoryRemains):
				can_place = false
		
		if (!can_place):
			if Input.is_action_just_pressed("lmb") and !placed:
				placed = true
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Requires factory remains!", structure_map.map_to_local(p), Color("6be1e3"))
			return 5
	
	var tech_slot: int
	# SPECIAL CASE FOR PLANTING TECH TREES ON FACTORY REMAINS:
	if (structure_map.tile_scene_map.has(p)):
		var structure: Structure = structure_map.tile_scene_map[p]
		if (structure is FactoryRemains):
			if (type == TreeType.TECH_TREE):
				tech_slot = structure.tech_slot
				structure_map.remove_structure(p)
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Only Tech Trees grow on factory remains!", structure_map.map_to_local(p), Color("6be1e3"))
				return 5
	placed = true
	
	if (tree is TechTree):
		tree.tech_slot = tech_slot
	
	#print("Forests: ", forests)
	res.x -= tree.tree_stat.cost_to_purchase
	var f_id: int = find_forest(p)
	forest_map[p] = f_id
	var forest: Forest = forests[f_id]
	forest.add_tree(p, tree)
	tree_map[p] = tree
	
	fog_map.remove_fog_around(p)
	
	if (type != 0): #check to make sure it's not mother tree
		SfxManager.play_sound_effect("tree_plant")
		print("done")
	
	#if (type == 0):
		#structure_map.add_structure(p + Vector2i.UP + Vector2i.LEFT, tree)
		#forest.add_tree(p + Vector2i.UP + Vector2i.LEFT, tree)
		#structure_map.add_structure(p + Vector2i.UP, tree)
		#forest.add_tree(p + Vector2i.UP, tree)
		#structure_map.add_structure(p + Vector2i.LEFT, tree)
		#forest.add_tree(p + Vector2i.LEFT, tree)
	
	# call structure_map to add it on screen TODO: weird 
	structure_map.add_structure(p, tree)
	
	# Don't emit for mother tree
	if (!tree is MotherTree):
		tree_placed.emit()
	
	#print_forest_map()
	
	return 0

## remove tree at given p
## returns false if no tree exists at p; true otherwise
func remove_tree(p: Vector2i) -> bool:
	if (!forest_map.has(p)):
		return false
	if (p == Global.ORIGIN): ## Game's effectively over. We want to do something *bombastic*
		var mother: MotherTree = tree_map[p]
		mother.die()
		return false
	var f_id = forest_map[p]
	var f: Forest = forests[f_id]
	var tree: Twee = f.trees[p]
	f.remove_tree(p)
	# assume remove_tree will free object correctly
	forest_map.erase(p)
	
	forest_check(p, f_id)
	structure_map.remove_structure(p)
	
	#print_forest_map()
	#print("Forests: ", forests)
	return true

func get_twee(p: Vector2i) -> Twee:
	var tree_map = get_tree_map()
	if (!tree_map.has(p)):
		return null
	
	return tree_map[p]


func remove_forest(id: int):
	if (!forests.has(id)):
		return
	var f: Forest = forests[id]
	for t in f.trees.keys():
		tree_map.erase(t)
	f.free()
	forests.erase(id)

## upgrade the tree at given p
## return: 0 -> succesfful, 1 -> no tree at p, 2 -> insufficient resources
##         3 -> secondary tree exists at p
func upgrade_tree(p: Vector2i) -> int:
	if (!forest_map.has(p)):
		return 1
	
	if (!enough_n(DefaultTree.COST2)):
		#print("not enough N")
		return 2
		
	var f_id = forest_map[p]
	var forest: Forest = forests[f_id]
	if (forest.upgrade(p)):
		# assume Forest.upgrade() erase and replace correctly
		res.x -= DefaultTree.COST2
		## ui stuff tbd
		#var object: BuildingMap = get_tree().get_first_node_in_group("structure_map")
		#object.upgrade_cell(p)
		return 0
	else: return 3


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
			var tree: Twee = tree_map[pos]
			
			# Add to forest
			new_forest.trees[pos] = tree
			
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


## same as remove_tree, but to distinguish manually removed trees and dead trees
func tree_die(p: Vector2i) -> bool:
	return remove_tree(p)

func print_forest_map():
	for key in forest_map:
		print(key, ", ", forest_map[key])

## called by Tree when they don't have sufficient water to survive
## returns false if total_water < maint; otherwise deduct maint from storage
func get_water(maint: int) -> bool:
	if (res.y < maint):
		return false
	else:
		res.y -= maint
		return true

## check if player has enough N
## if yes, spend required N and returns true; returns false otherwise
func enough_n(cost: int) -> bool:
	if (res.x >= cost):
		return true
	return false

func get_forest(id: int) -> Forest:
	return forests[id]

func get_tree_map() -> Dictionary[Vector2i, Twee]:
	
	var tree_map: Dictionary[Vector2i, Twee]
	for key in forests:
		var forest: Forest = forests[key]
		
		for pos in forest.trees:
			tree_map[pos] = forest.trees[pos]
	
	return tree_map
# function for testing, remove eventually
func print_trees():
	var tree_map = get_tree_map()
	for key in tree_map:
		var tree: DefaultTree = tree_map[key]
		print(key, tree.storage)
	print()

## POSITION CHECKS

func is_reachable(pos: Vector2i, include_trees: bool = false):
	return get_reachable_tree_placement_positions(include_trees).has(pos)

func is_occupied(pos: Vector2i):
	return get_tree_map().has(pos)

func is_large(pos: Vector2i):
	if !is_occupied(pos):
		return false
	return (get_tree_map().get(pos) as Twee).is_large

func is_stump(pos: Vector2i):
	var tree_map = get_tree_map()
	if not tree_map.has(pos):
		return false
	return (tree_map.get(pos) as Twee).died

func get_reachable_tree_placement_positions(include_trees: bool = false) -> Array[Vector2i]:
	var allowed_positions: Array[Vector2i] = []
	
	var tree_map = get_tree_map()
	
	for pos in tree_map.keys():
		var tree: Twee = tree_map.get(pos)
		for offset in tree.get_reachable_offsets():
			var new_pos = pos + offset
			if not tree_map.has(new_pos):
				allowed_positions.append(pos + offset)
		
		if (include_trees):
			allowed_positions.append(pos)
	
	return allowed_positions

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
		# remove these from old forest
		old_f.trees.erase(pos)
	
		## update some info
		#if (pos == Global.ORIGIN):
			#continue
		var tree = tree_map[pos]
		tree.forest = id
		forest_map[pos] = id
		
		# add this to new forest
		forest.trees[pos] = tree
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

func is_mother_dead() -> bool:
	return (!tree_map.has(Global.ORIGIN) or tree_map[Global.ORIGIN].died)



const FACTORY_REMAINS = preload("res://trees/scripts/factory_remains.tscn")

func handle_right_click(map_pos: Vector2i):
	if (!is_reachable(map_pos, true)):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup("Too far away!", structure_map.map_to_local(map_pos))
		return
	
	# Get any building on the tile
	if (structure_map.does_obstructive_structure_exist(map_pos)):
		var structure: Structure = structure_map.tile_scene_map[map_pos]
		
		# If building is tree, remove tree and return (unless it's the mother tree)
		if (structure is Twee):
			if (structure is MotherTree):
				PopupManager.create_popup("Cannot remove mother tree!", structure_map.map_to_local(map_pos))
				SfxManager.play_sound_effect("ui_fail")
				return
			
			remove_tree(map_pos)
			PopupManager.create_popup("Tree removed!", structure_map.map_to_local(map_pos))
		
		# If building is city_building, remove city_building (if you have enough nutrients)
		if (structure is CityBuilding):
			if (res.x > structure.cost_to_remove):
				SfxManager.play_sound_effect("concrete_break")
				res.x -= structure.cost_to_remove
				structure_map.remove_structure(map_pos)
				PopupManager.create_popup("Building destroyed!", structure_map.map_to_local(map_pos))
				
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
		
		# If building is factory, remove factory, instantiate factory remains
		if (structure is Factory):
			if (res.x > structure.cost_to_remove):
				
				res.x -= structure.cost_to_remove
				
				var tech_slot = structure.tech_slot
				structure_map.remove_structure(map_pos)
				
				terrain_map.set_cell_type(map_pos, terrain_map.TILE_TYPE.DIRT)
				
				SfxManager.play_sound_effect("concrete_break")
				PopupManager.create_popup("Factory destroyed!", structure_map.map_to_local(map_pos))
				
				# TODO: INSTANTIATE FACTORY REMAINS
				var factory_remains = FACTORY_REMAINS.instantiate()
				factory_remains.tech_slot = tech_slot
				structure_map.add_structure(map_pos, factory_remains)
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
		
		if (structure is FactoryRemains):
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup("Cannot destroy factory remains!", structure_map.map_to_local(map_pos))
		
		# Return after removing building
		return
	
	# IF THERE ARE NO STRUCTURES (except decor) ON THE TILE
	
	# If tile is city_tile/road_tile, replace tile with dirt tile if you have enough nutrients
	
	var tile_data = terrain_map.get_cell_tile_data(map_pos)
	if (tile_data):
		var tile_type = tile_data.get_custom_data("biome")
		
		if (tile_type == terrain_map.TILE_TYPE.CITY):
			if (res.x > structure_map.COST_TO_REMOVE_CITY_TILE):
				
				res.x -= structure_map.COST_TO_REMOVE_CITY_TILE
				terrain_map.set_cell_type(map_pos, terrain_map.TILE_TYPE.DIRT)
				
				# Check if decor exists on this spot
				if (structure_map.tile_scene_map.has(map_pos) && !structure_map.does_obstructive_structure_exist(map_pos)):
					structure_map.remove_structure(map_pos)
				
				SfxManager.play_sound_effect("concrete_break")
				PopupManager.create_popup("Concrete removed!", structure_map.map_to_local(map_pos))
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
		
		if (tile_type == terrain_map.TILE_TYPE.ROAD):
			if (res.x > structure_map.COST_TO_REMOVE_ROAD_TILE):
				
				res.x -= structure_map.COST_TO_REMOVE_ROAD_TILE
				terrain_map.set_cell_type(map_pos, terrain_map.TILE_TYPE.DIRT)
				
				# Check if decor exists on this spot
				if (structure_map.tile_scene_map.has(map_pos) && !structure_map.does_obstructive_structure_exist(map_pos)):
					structure_map.remove_structure(map_pos)
				
				SfxManager.play_sound_effect("concrete_break")
				PopupManager.create_popup("Road destroyed!", structure_map.map_to_local(map_pos))
			else:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup("Not enough nutrients!", structure_map.map_to_local(map_pos))
	
	
	
	# Delete decor
