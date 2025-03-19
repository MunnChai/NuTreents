extends Node
class_name tree_manager

# stores all trees
var forests: Dictionary[int, Forest] # {id, Forest}
var forest_map: Dictionary[Vector2i, int] # {pos, id}
var tree_map: Dictionary[Vector2i, Node2D]
var res: Vector3

func _ready():
	res = Vector3(15, 4, 0)
	test()
	
	add_tree(1, Vector2i(1,0))
	upgrade_tree(Vector2i(1,0))
	print_trees()
	print_res()

func test():
	# testing
	var button = Button.new()
	button.text = "Update Resource (used for TreeManager Testing)"
	button.pressed.connect(_button_pressed)
	button.set_position(Vector2i(0,-100))
	add_child(button)
	
	
func _button_pressed():
	update()
	print_trees()
	print_res()

## to be called each round, update everything?
func update():
	# iterate all trees, get their generated res and remove dead trees
	for key in forests.keys():
		var f: Forest = forests[key]
		res += f.update()


## add tree with given type at p
# TODO type: will add more types later, codes only use DefaultTree for now
## return: 0 -> successful, 1 -> unavailable space, 2-> insufficient resources
func add_tree(type: int, p: Vector2i) -> int:
	if (forest_map.has(p)):
		return 1
	if (!enough_n(DefaultTree.COST1)):
		print("not enough N")
		return 2
	
	var f_id: int = find_forest(p)
	forest_map[p] = f_id
	var forest: Forest = forests[f_id]
	forest.add_tree(p, DefaultTree.new(0, p, f_id))
	
	# call structure_map to add it on screen TODO: weird 
	#var object = get_tree().get_first_node_in_group("structure_map")
	#print("Found node:", object, "Type:", object.get_class())
	#object.add_default_tree(p)
	return 0

## remove tree at given p
## returns false if no tree exists at p; true otherwise
func remove_tree(p: Vector2i) -> bool:
	if (!tree_map.has(p)):
		return false
	var f_id = forest_map[p]
	var forest: Forest = forests[f_id]
	if (!remove_tree(p)):
		return false
	# assume remove_tree will free object correctly
	forest_map.erase(p)
	return true

## upgrade the tree at given p
## return: 0 -> succesfful, 1 -> no tree at p, 2 -> insufficient resources
##         3 -> secondary tree exists at p
func upgrade_tree(p: Vector2i) -> int:
	if (!tree_map.has(p)):
		return 1
		
	var original_tree: DefaultTree = tree_map[p]
	if (original_tree.level == 2):
		return 3
		
	if (!enough_n(DefaultTree.COST2)):
		print("not enough N")
		return 2
		
	tree_map.erase(p)
	var new_tree: DefaultTree = original_tree.upgrade()
	tree_map[p] = new_tree
	original_tree.free()
	
	#var object: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	#object.upgrade_cell(p)
	return 0

## finds the corresponding forest number for given p
func find_forest(p: Vector2i):
	return 1


## same as remove_tree, but to dstinguish manually removed trees and dead trees
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
		res.x -= cost
		return true
	return false


## function for testing, remove eventually
func print_trees():
	for key in tree_map.keys():
		var tree: DefaultTree = tree_map[key]
		print(key, ": water ", tree.storage, "  hp ", tree.hp)

## function for testing as well
func print_res():
	print(res)
