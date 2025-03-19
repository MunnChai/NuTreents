extends Node
class_name Forest

var trees: Dictionary[Vector2i, Node2D]
var water: int
var id: int

func _init(i: int):
	water = 0
	id = i
	
	
## to be called each round, update everything in this Forest
## returns the res to be added to the game
func update() -> Vector3:
	# iterate all trees, get their generated res and remove dead trees
	var res = Vector3(0,0,0)
	for key in trees.keys():
		if (!trees.has(key)):
			continue
		var tree: Twee = trees[key]
		res += tree.update()
		if (tree.died):
			#remove_tree(key)
			return res
	return res

## add tree of given type to this forest
func add_tree(p: Vector2i, t: Twee):
	trees[p] = t

## remove the tree at given p
## returns false if no tree exists at p; true otherwise
func remove_tree(p: Vector2i) -> bool:
	if (!trees.has(p)):
		return false
	var t: Twee = trees[p]
	water -= t.storage
	t.free()
	trees.erase(p)
	return true

## upgrade the tree at given p
## return: 0 -> succesfful, 1 -> no tree at p, 2 -> insufficient resources
##         3 -> secondary tree exists at p
func upgrade(p: Vector2i) -> int:
	return 0

## called by Tree when they don't have sufficient water to survive
## returns false if total_water < maint; otherwise deduct maint from storage
func get_water(maint: int) -> bool:
	if (water < maint):
		return false
	else:
		water -= maint
		return true
