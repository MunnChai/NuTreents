class_name TargetingComponent
extends Node2D

func get_nearest_enemy(map_position: Vector2i) -> Node2D:
	var nearest_enemy: Node2D = null
	var nearest_enemy_pos = Vector2i.ZERO
	var nearest_dist: float = INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_pos_component = Components.get_component(enemy, GridPositionComponent)
		
		for pos in enemy_pos_component.get_occupied_positions():
			var dist = MapUtility.get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_enemy = enemy
				nearest_enemy_pos = pos
				nearest_dist = dist
	
	return nearest_enemy

func get_nearest_enemy_pos(map_position: Vector2i) -> Vector2i:
	var nearest_enemy: Node2D = null
	var nearest_enemy_pos = Vector2i.ZERO
	var nearest_dist: float = INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_pos_component = Components.get_component(enemy, GridPositionComponent)
		
		for pos in enemy_pos_component.get_occupied_positions():
			var dist = MapUtility.get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_enemy = enemy
				nearest_enemy_pos = pos
				nearest_dist = dist
	
	return nearest_enemy_pos

## Returns the nearest tree from the given map position
func get_nearest_tree(map_position: Vector2i) -> Node2D:
	var tree_map: Dictionary[Vector2i, Node2D] = TreeManager.get_tree_map()
	if (tree_map.is_empty()):
		return null
	
	var nearest_tree: Node2D = null
	var nearest_tree_pos = Vector2i.ZERO
	var nearest_dist: float = INF
	for key in tree_map:
		var tree: Node2D = tree_map[key]
		var health_component: HealthComponent = Components.get_component(tree, HealthComponent)
		if (health_component.is_dead):
			continue
		
		for pos in tree.grid_position_component.get_occupied_positions():
			var dist = MapUtility.get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_tree = tree
				nearest_tree_pos = pos
				nearest_dist = dist
	
	return nearest_tree

## Returns the nearest position that has a tree on it
func get_nearest_tree_pos(map_position: Vector2i):
	var tree_map: Dictionary[Vector2i, Node2D] = TreeManager.get_tree_map()
	if (tree_map.is_empty()):
		return null
	
	var nearest_tree: Node2D = null
	var nearest_tree_pos = null
	var nearest_dist: float = INF
	for key in tree_map:
		var tree: Node2D = tree_map[key]
		var health_component: HealthComponent = Components.get_component(tree, HealthComponent)
		if (health_component.is_dead):
			continue
		
		for pos in tree.grid_position_component.get_occupied_positions():
			var dist = MapUtility.get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_tree = tree
				nearest_tree_pos = pos
				nearest_dist = dist
	
	return nearest_tree_pos
