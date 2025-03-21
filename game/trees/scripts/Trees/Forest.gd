extends Node
class_name Forest

var trees: Dictionary[Vector2i, Node2D]
var water: int
var id: int
var empty: bool

func _init(i: int):
	water = 0
	id = i
	empty = false
	
## to be called each round, update everything in this Forest
## returns the res to be added to the game
func update(delta: float) -> Vector3:
	water = 0
	for key in trees.keys():
		if (!trees.has(key)):
			continue
		var tree: Twee = trees[key]
		water += tree.storage
	
	# iterate all trees, get their generated res and remove dead trees
	var res = Vector3(0,0,0)
	for key in trees.keys():
		if (!trees.has(key)):
			continue
		var tree: Twee = trees[key]
		res += tree.update(delta)
		if (tree.died):
			remove_tree(key)
			pass
	
	return res

## add the given tree to this forest
func add_tree(p: Vector2i, t: Twee):
	t.initialize(p, id)
	trees[p] = t

## remove the tree at given p
## assume some tree exists at p
func remove_tree(p: Vector2i):
	if (!trees.has(p)):
		return
	var t: Twee = trees[p]
	water -= t.storage
	trees.erase(p)
	TreeManager.remove_tree(p)
	

## upgrade the tree at given p
## returns false if tree at p is already secondary 
func upgrade(p: Vector2i) -> int:
	var tree: DefaultTree = trees[p]
	if (tree.level == 2):
		return false
	trees.erase(p)
	trees[p] = tree.upgrade()
	tree.free()
	return true

## called by Tree when they don't have sufficient water to survive
## returns false if total_water < maint; otherwise deduct maint from storage
func get_water(maint: int) -> bool:
	if (water < maint):
		return false
	else:
		water -= maint
		return true


func print_forest():
	for key in trees.keys():
		var t: DefaultTree = trees[key]
		print("level:", t.level, " hp:", t.hp, " water:", t.storage, " f:", t.forest)
