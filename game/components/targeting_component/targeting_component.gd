class_name TargetingComponent
extends Node2D

@export var ignore_structures: bool

var currently_targeting

func get_nearest_enemy(map_position: Vector2i) -> Enemy:
	return null

## Returns the nearest tree from the given map position
func get_nearest_tree(map_position: Vector2i) -> Twee:
	var tree_map: Dictionary[Vector2i, Twee] = TreeManager.get_tree_map()
	if (tree_map.is_empty()):
		return null
	
	var nearest_tree: Twee = null
	var nearest_tree_pos = Vector2i.ZERO
	var nearest_dist: float = INF
	for key in tree_map:
		var tree: Twee = tree_map[key]
		if (tree.died):
			continue
		
		for pos in tree.get_occupied_positions():
			# Check if tree is surrounded
			var surrounding_directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
			var completely_obstructed = true
			for direction in surrounding_directions:
				if not Global.structure_map.does_obstructive_structure_exist(pos + direction):
					completely_obstructed = false
					break
			
			if completely_obstructed and not ignore_structures:
				continue
			
			var dist = get_taxicab_distance(pos, map_position)
			if (dist < nearest_dist):
				nearest_tree = tree
				nearest_tree_pos = pos
				nearest_dist = dist
	
	currently_targeting = nearest_tree
	return nearest_tree

func get_taxicab_distance(pos_a: Vector2i, pos_b: Vector2i) -> int:
	return abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y)
