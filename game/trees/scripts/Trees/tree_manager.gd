extends Node
class_name tree_manager

# stores all trees
var forests: Dictionary[int, Forest] # {id, Forest}
var forest_map: Dictionary[Vector2i, int] # {pos, id}
var res: Vector3
var forest_count: int

func _ready():
	res = Vector3(15, 4, 0)
	forest_count = 0
	test()


func test():
	# testing
	var button = Button.new()
	button.text = "Update Resource (used for TreeManager Testing)"
	button.pressed.connect(_button_pressed)
	button.set_position(Vector2i(0,-100))
	add_child(button)
		
	add_tree(1, Vector2i(1,0))
	upgrade_tree(Vector2i(1,0))
	
	
func _button_pressed():
	update()
	
	
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
	if (!forest_map.has(p)):
		return false
	var f_id = forest_map[p]
	var forest: Forest = forests[f_id]
	remove_tree(p)
	# assume remove_tree will free object correctly
	forest_map.erase(p)
	return true

## upgrade the tree at given p
## return: 0 -> succesfful, 1 -> no tree at p, 2 -> insufficient resources
##         3 -> secondary tree exists at p
func upgrade_tree(p: Vector2i) -> int:
	if (!forest_map.has(p)):
		return 1
	
	if (!enough_n(DefaultTree.COST2)):
		print("not enough N")
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
	var adjacent_forests = []
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
	return 1


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
		res.x -= cost
		return true
	return false
