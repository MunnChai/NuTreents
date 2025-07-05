extends Node
class_name Forest

var trees: Dictionary[Vector2i, Node2D]
var tree_set: Array[Node2D]
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
	if total == 0: return Vector2.ZERO
	return sum / float(total)

func distance_from_average_pos(pos: Vector2i) -> float:
	return Vector2(pos).distance_squared_to(get_average_pos())

func sort_close_to_far(a, b):
	if distance_from_average_pos(a) < distance_from_average_pos(b):
		return true
	return false

## DEPRECATED
func update(delta: float) -> Vector3:
	# ... (existing deprecated code) ...
	return Vector3.ZERO

# Returns the sum of nutrient gains of all the trees in this forest
func get_nutrient_gain() -> float:
	var nutrient_sum: float = 0
	for tree: Node2D in tree_set:
		if is_instance_valid(tree): # Safety check
			var nutreent_production_component = Components.get_component(tree, NutreentProductionComponent)
			if nutreent_production_component:
				nutrient_sum += nutreent_production_component.get_nutreent_production()
	return nutrient_sum

var notification: Notification

func update_water_maintenance(delta: float) -> float:
	var net_water_change: float = 0.0

	var keys_to_remove = []
	for pos in trees.keys():
		var tree_node = trees.get(pos)
		
		# --- FIX 1: Safety Check ---
		# This check is crucial. If the tree node was deleted, we mark its
		# position for removal from our dictionary to prevent future errors.
		if not is_instance_valid(tree_node):
			keys_to_remove.append(pos)
			continue # Skip to the next tree

		var water_production_component: WaterProductionComponent = Components.get_component(tree_node, WaterProductionComponent)
		if not water_production_component:
			continue

		var base_water_change = water_production_component.get_water_production()
		var base_production = max(0, base_water_change)
		var base_consumption = abs(min(0, base_water_change))

		var tile_effects: Dictionary = Global.terrain_map.get_tile_effects(pos)
		var water_prod_mod: float = tile_effects.get("water_production_modifier", 1.0)
		var water_cons_mod: float = tile_effects.get("water_consumption_modifier", 1.0)
		
		var temperature: float = Global.terrain_map.get_real_temperature(pos)
		var temp_prod_mod: float = 1.0
		var temp_cons_mod: float = 1.0

		if temperature > 35.0:
			temp_cons_mod = 1.5
		elif temperature < 5.0:
			temp_cons_mod = 0.7
			temp_prod_mod = 0.8
		elif temperature < -2.0:
			temp_cons_mod = 0.1
			temp_prod_mod = 0.0
		
		var final_production = base_production * water_prod_mod * temp_prod_mod
		var final_consumption = base_consumption * water_cons_mod * temp_cons_mod
		net_water_change += (final_production - final_consumption)
	
	# --- FIX 2: Clean up dangling references ---
	# Remove all the invalid trees we found from our dictionary.
	for key in keys_to_remove:
		trees.erase(key)

	var is_forest_dehydrated: bool = (water + net_water_change * delta) < 0
	
	var could_be_visibly_dehydrated: bool = false
	
	for pos in trees.keys():
		var tree_node = trees.get(pos)
		if not is_instance_valid(tree_node):
			continue # Add safety check to the second loop as well
		
		var twee_behaviour_component: TweeBehaviourComponent = Components.get_component(tree_node, TweeBehaviourComponent)
		var water_comp: WaterProductionComponent = Components.get_component(tree_node, WaterProductionComponent)
		
		if not water_comp.is_water_adjacent():
			could_be_visibly_dehydrated = true

		
		if not is_forest_dehydrated or water_comp.is_water_adjacent():
			if twee_behaviour_component: twee_behaviour_component.is_dehydrated = false
		else:
			if twee_behaviour_component: twee_behaviour_component.is_dehydrated = true

	## HANDLE showing notification for dehydrated forests
	if is_forest_dehydrated and could_be_visibly_dehydrated:
		if not notification or notification.is_removed:
			notification = Notification.new(&"dehydration", '[color=ff5671][url="goto"]A part of your forest is dehydrated.[/url]', { "priority": 10, "time_remaining": 1.0, "position": get_average_pos() });
			NotificationLog.instance.add_notification(notification)
		else:
			notification.properties["time_remaining"] = 1.0
	else:
		if notification:
			notification.remove()

	water += net_water_change * delta
	water = max(water, 0)
	water_gain = net_water_change
	return net_water_change

## add the given tree to this forest
func add_tree(p: Vector2i, t: Node2D):
	var tree_behaviour_component: TweeBehaviourComponent = Components.get_component(t, TweeBehaviourComponent)
	if tree_behaviour_component:
		tree_behaviour_component.set_forest(id)
	trees[p] = t
	add_tree_to_set(t)

func add_tree_to_set(t: Node2D):
	if not tree_set.has(t):
		tree_set.append(t)

func remove_tree_from_set(t: Node2D):
	tree_set.erase(t)

## remove the tree at given p
## assume some tree exists at p
func remove_tree(p: Vector2i):
	if (!trees.has(p)):
		return
	var t: Node2D = trees[p]
	trees.erase(p)
	if is_instance_valid(t): # Only try to erase if it's a valid object
		tree_set.erase(t)

## DEPRECATED
func upgrade(p: Vector2i) -> int:
	var tree: Node # Use a generic Node type to avoid class errors
	if trees.has(p):
		tree = trees[p]
	else:
		return false

	if tree.has_method("get_level") and tree.get_level() == 2:
		return false
	if tree.has_method("upgrade"):
		var new_tree = tree.upgrade()
		if is_instance_valid(new_tree):
			trees[p] = new_tree
			tree.queue_free()
			return true
	return false

## DEPRECATED
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
