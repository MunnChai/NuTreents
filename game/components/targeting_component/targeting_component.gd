class_name TargetingComponent
extends Node2D

@export var ignore_structures: bool

var currently_targeting

func get_nearest_enemy(map_position: Vector2i) -> Enemy:
	# TODO: implement linear search
	return null

## Returns the nearest tree from the given map position
func get_nearest_tree(map_position: Vector2i) -> TweeComposed:
	var tree_map: Dictionary[Vector2i, TweeComposed] = TreeManager.get_tree_map()
	if (tree_map.is_empty()):
		return null
	
	var nearest_tree: TweeComposed = null
	var nearest_tree_pos = Vector2i.ZERO
	var nearest_dist: float = INF
	for key in tree_map:
		var tree: TweeComposed = tree_map[key]
		if (tree.died):
			continue
		
		for pos in tree.grid_position_component.get_occupied_positions():
			var dist = MapUtility.get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_tree = tree
				nearest_tree_pos = pos
				nearest_dist = dist
	
	currently_targeting = nearest_tree
	return nearest_tree

## Returns the nearest position that has a tree on it
func get_nearest_tree_pos(map_position: Vector2i):
	var tree_map: Dictionary[Vector2i, TweeComposed] = TreeManager.get_tree_map()
	if (tree_map.is_empty()):
		return null
	
	var nearest_tree: TweeComposed = null
	var nearest_tree_pos = null
	var nearest_dist: float = INF
	for key in tree_map:
		var tree: TweeComposed = tree_map[key]
		if (tree.died):
			continue
		
		for pos in tree.grid_position_component.get_occupied_positions():
			var dist = MapUtility.get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_tree = tree
				nearest_tree_pos = pos
				nearest_dist = dist
	
	currently_targeting = nearest_tree
	return nearest_tree_pos
