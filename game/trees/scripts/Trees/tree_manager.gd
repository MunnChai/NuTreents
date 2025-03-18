extends Node
class_name tree_manager

# stores all trees
var tree_map: Dictionary[Vector2i, Node2D]
var res: Vector3

func _ready():
	res = Vector3(0, 0, 0)
	
	# testing
	var button = Button.new()
	button.text = "Update Resource"
	button.pressed.connect(_button_pressed)
	add_child(button)
	#await get_tree().process_frame
	add_tree(1, Vector2i(1,0))
	add_tree(1, Vector2i(1,1))
	upgrade_tree(Vector2i(1,1))

func _button_pressed():
	update()
	print_trees()
	print_res()

# to be called each round, update everything?
func update():
	# iterate all trees, get their generated res and remove dead trees
	for key in tree_map.keys():
		if (!tree_map.has(key)):
			continue
		var tree: Twee = tree_map[key]
		res += tree.get_gain()
		tree.update_maint()
		if (tree.died):
			remove_tree(key)


# add tree with given type at p
# TODO type: will add more types later, codes only use DefaultTree for now
# return: 0 -> successful, 1 -> unavailable space, 2-> insufficient resources
func add_tree(type: int, p: Vector2i) -> int:
	if (tree_map.has(p)):
		return 1
	var tree = DefaultTree.new(0, p)
	tree_map[p] = tree
	
	# call structure_map to add it on screen TODO: weird 
	#var object = get_tree().get_first_node_in_group("structure_map")
	#print("Found node:", object, "Type:", object.get_class())
	#object.add_default_tree(p)
	return 0

# remove tree at given p
# returns false if no tree exists at p; true otherwise
func remove_tree(p: Vector2i) -> bool:
	if (!tree_map.has(p)):
		return false
	var tree = tree_map[p]
	tree_map.erase(p)
	tree.free()
	return true

# same as remove_tree, but to dstinguish manually removed trees and dead trees
func tree_die(p: Vector2i) -> bool:
	return remove_tree(p)

# upgrade the tree at given p
# return: 0 -> succesfful, 1 -> no tree at p, 2 -> insufficient resources
#         3 -> secondary tree exists at p
func upgrade_tree(p: Vector2i) -> int:
	if (!tree_map.has(p)):
		return 1
		
	var original_tree: DefaultTree = tree_map[p]
	if (original_tree.level == 2):
		return 3
		
	tree_map.erase(p)
	var new_tree: DefaultTree = original_tree.upgrade()
	tree_map[p] = new_tree
	original_tree.free()
	
	#var object: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	#object.upgrade_cell(p)
	return 0


# called by Tree when they don't have sufficient water to survive
# returns false if total_water < maint; otherwise deduct maint from storage
func get_water(maint: int) -> bool:
	if (res.y < maint):
		return false
	else:
		res.y -= maint
		return true



# function for testing, remove eventually
func print_trees():
	for key in tree_map.keys():
		var tree: DefaultTree = tree_map[key]
		print(key, ": water ", tree.storage, "  hp ", tree.hp)

# function for testing as well
func print_res():
	print(res)
