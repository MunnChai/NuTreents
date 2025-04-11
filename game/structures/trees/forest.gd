extends Node
class_name Forest

var trees: Dictionary[Vector2i, Node2D]
var water: float
var id: int
var empty: bool

var water_gain: float

func _init(i: int):
	water = 0
	id = i
	empty = false

func get_average_pos() -> Vector2:
	var sum = Vector2.ZERO
	var total = 0
	for pos in trees.keys():
		sum += Vector2(pos)
		total += 1
	return sum / float(total)

func distance_from_average_pos(pos: Vector2i) -> float:
	return Vector2(pos).distance_squared_to(get_average_pos())

func sort_close_to_far(a, b):
	if distance_from_average_pos(a) < distance_from_average_pos(b):
		return true
	return false

## to be called each round, update everything in this Forest
## returns the res to be added to the game
func update(delta: float) -> Vector3:
	var sorted_trees = trees.keys()
	#sorted_trees.sort_custom(sort_close_to_far)
	
	water = 0
	for key in sorted_trees:
		if (!trees.has(key)):
			continue
		if (!trees[key]):
			trees.erase(key)
			continue
		var tree: Twee = trees[key]
		water += tree.gain.y
	
	for key in sorted_trees:
		if (!trees.has(key)):
			continue
		var tree: Twee = trees[key]
		water -= tree.maint
		
		if (water < 0):
			if (TreeManager.res.y == 0):
				if (tree.is_adjacent_to_water):
					tree.is_dehydrated = false
				else:
					tree.is_dehydrated = true
					
					while (tree.water_damage_time > tree.WATER_DAMAGE_DELAY):
						tree.take_damage(tree.DEHYDRATION_DAMAGE)
						tree.water_damage_time -= RandomNumberGenerator.new().randf_range(tree.WATER_DAMAGE_DELAY, tree.WATER_DAMAGE_DELAY * 2)
					tree.water_damage_time += delta
			else:
				tree.is_dehydrated = false
		else:
			tree.is_dehydrated = false
		
		tree._update_shader(delta)
	
	# iterate all trees, get their generated res and remove dead trees
	var res = Vector3(0,0,0)
	for key in sorted_trees:
		if (!trees.has(key)):
			continue
		var tree: Twee = trees[key]
		res += tree.update(delta)
	
	# Ignore water from update, just set what we calculated earlier
	res.y = water
	
	return res

# Returns the sum of nutrient gains of all the trees in this forest
func get_nutrient_gain(delta: float) -> float:
	var nutrient_sum: float = 0
	
	for key: Vector2i in trees.keys():
		if (!trees.has(key)):
			continue
		
		var tree: Twee = trees[key]
		
		nutrient_sum += tree.get_nutrient_gain(delta)
	
	return nutrient_sum

func update_water_maintenance(delta: float) -> float:
	var sorted_trees = trees.keys()
	#sorted_trees.sort_custom(sort_close_to_far)
	
	var net_water: float = 0
	for key in sorted_trees:
		if (!trees.has(key)):
			continue
		if (!trees[key]):
			trees.erase(key)
			continue
		var tree: Twee = trees[key]
		net_water += tree.gain.y
	
	for key in sorted_trees:
		if (!trees.has(key)):
			continue
		var tree: Twee = trees[key]
		net_water -= tree.get_water_maint()
		
		if (net_water < 0): # If the gain for this forest does not outweigh the maintenance
			if (water <= 0): # Check THIS forest's water supply
				if (tree.is_adjacent_to_water): # If the tree is next to water, don't be dehydrated
					tree.is_dehydrated = false
				else:
					tree.is_dehydrated = true
					
					while (tree.water_damage_time > tree.WATER_DAMAGE_DELAY):
						tree.take_damage(tree.DEHYDRATION_DAMAGE)
						tree.water_damage_time -= RandomNumberGenerator.new().randf_range(tree.WATER_DAMAGE_DELAY, tree.WATER_DAMAGE_DELAY * 2)
					tree.water_damage_time += delta
			else:
				tree.is_dehydrated = false
		else:
			tree.is_dehydrated = false
		
		tree._update_shader(delta)
	
	water += net_water * delta
	water = clamp(water, 0, INF)
	
	water_gain = net_water
	
	return net_water


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
	
	t.die()

## upgrade the tree at given p
## returns false if tree at p is already secondary 
func upgrade(p: Vector2i) -> int:
	var tree: Twee = trees[p]
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
	print("Forest ID:", id)
	for key in trees.keys():
		print("Tree: ", key)
	print()
