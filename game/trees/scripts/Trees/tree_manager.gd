extends Node
class_name tree_manager

@onready var fog_map: FogMap = get_tree().get_nodes_in_group("fog_map")[0]
@onready var structure_map: BuildingMap = get_tree().get_nodes_in_group("structure_map")[0]
@onready var terrain_map: TerrainMap = get_tree().get_nodes_in_group("terrain_map")[0]

const MOTHER_TREE = preload("res://trees/scenes/MotherTree.tscn")
const DEFAULT_TREE = preload("res://trees/scenes/DefaultTree.tscn")
const GUN_TREE = preload("res://trees/scenes/GunTree.tscn")

const TREE_DICT: Dictionary[int, PackedScene] = {
	0: MOTHER_TREE,
	1: DEFAULT_TREE,
	2: GUN_TREE,
}


# stores all trees
var forests: Dictionary[int, Forest] # {id, Forest}
var forest_map: Dictionary[Vector2i, int] # {pos, id}
var res: Vector3 # Vec3(N, water, sun)
var forest_count: int

func _ready():
	res = Vector3(10, 0, 0)
	forest_count = 0
	#test()
	
	call_deferred("add_tree", 0, Constants.MAP_SIZE / 2, false)

func _process(delta):
	update(delta)

func _input(_event: InputEvent) -> void:
	
	if (Input.is_action_pressed("lmb")):
		var map_coords: Vector2i = structure_map.local_to_map(structure_map.get_mouse_coords())
		
		add_tree(2, map_coords)
	
	if (Input.is_action_pressed("rmb")):
		var map_coords: Vector2i = structure_map.local_to_map(structure_map.get_mouse_coords())
		
		remove_tree(map_coords)


func test():
	# testing
	var button = Button.new()
	button.text = "Update Resource (Forest and TreeManager testing)"
	button.pressed.connect(_button_pressed)
	button.set_position(Vector2i(0,-100))
	add_child(button)
	print(remove_tree(Vector2i(1,0)))
	print(add_tree(1, Vector2i(1,0)))
	res = Vector3(10, 4, 0)
	print(add_tree(1, Vector2i(1,0)))
	print(upgrade_tree(Vector2i(1,1)))
	print(upgrade_tree(Vector2i(1,0)))
	res.x += 20
	print(upgrade_tree(Vector2i(1,0)))
	forests[1].print_forest()
	print(forest_map)
	
	
func _button_pressed():
	update(1.0)
	var f: Forest = forests[1]
	f.print_forest()
	print(forest_map)
	
## to be called each round, update everything?
func update(delta: float):
	# iterate all trees, get their generated res and remove dead trees
	for key in forests.keys():
		var f: Forest = forests[key]
		res += f.update(delta) * delta
		if (f.empty):
			remove_forest(key)  


## add tree with given type at p
# TODO type: will add more types later, codes only use DefaultTree for now
## return: 0 -> successful, 1 -> unavailable space, 2-> insufficient resources
func add_tree(type: int, p: Vector2i, enforce_reachable: bool = true) -> int:
	var tree: Twee
	tree = TREE_DICT[type].instantiate()
	
	if (forest_map.has(p)):
		return 1
	if (!enough_n(tree.tree_stat.cost_to_purchase)):
		print("not enough N")
		return 2
	if not terrain_map.is_fertile(p):
		return 3 
	if enforce_reachable and not is_reachable(p):
		return 4
	
	res.x -= tree.tree_stat.cost_to_purchase
	
	var f_id: int = find_forest(p)
	forest_map[p] = f_id
	var forest: Forest = forests[f_id]
	forest.add_tree(p, tree)
	
	fog_map.remove_fog_around(p)
	
	# call structure_map to add it on screen TODO: weird 
	structure_map.add_structure(p, tree)
	return 0

## remove tree at given p
## returns false if no tree exists at p; true otherwise
func remove_tree(p: Vector2i) -> bool:
	if (!forest_map.has(p)):
		return false
	var f_id = forest_map[p]
	var f: Forest = forests[f_id]
	f.remove_tree(p)
	# assume remove_tree will free object correctly
	forest_map.erase(p)
	
	structure_map.remove_structure(p)
	return true

func remove_forest(id: int):
	if (!forests.has(id)):
		return
	var f: Forest = forests[id]
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
func find_forest(p: Vector2i):
	if (forest_map.has(p)):
		return forest_map[p]
	# TODO: find forest adjacent to p
	var adjacent_forests: Array[int] = []
	var directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	for dir in directions:
		var neighbour = p + dir
		if (forest_map.has(neighbour)):
			adjacent_forests.append(forest_map[neighbour])
	
	if (adjacent_forests.is_empty()):
		# no forests near p, then p is the new forest
		forest_count += 1
		forest_map[p] = forest_count
		forests[forest_count] = Forest.new(forest_count)
		return forest_count
	
	# TODO: if there are forest(s) near p, merge them together into new forest and assign p to that forest
	return merge_forests(adjacent_forests)[0]

## use divide-and-conquer to merge a set of Forests
## only used pseudocode before let's see if actually works
func merge_forests(forests: Array[int]) -> Array[int]:
	if (forests.size() == 1):
		# base case: merging is done
		return forests
	var mid: int = forests.size() / 2
	# both left and right should be [i]
	var left = merge_forests(forests.slice(0, mid))
	var right = merge_forests(forests.slice(mid, forests.size()))
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

func is_reachable(pos: Vector2i):
	return get_reachable_tree_placement_positions().has(pos)

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

func get_reachable_tree_placement_positions() -> Array[Vector2i]:
	var allowed_positions: Array[Vector2i] = []
	
	var tree_map = get_tree_map()
	
	for pos in tree_map.keys():
		var tree: Twee = tree_map.get(pos)
		for offset in tree.get_reachable_offsets():
			var new_pos = pos + offset
			if not tree_map.has(new_pos):
				allowed_positions.append(pos + offset)
	
	return allowed_positions
