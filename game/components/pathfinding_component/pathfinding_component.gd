class_name PathfindingComponent
extends Node2D

@export var obstructive_tiles: Array[TerrainMap.TileType]
@export var ignore_structures: bool
@export var ignore_entities: bool

var current_path: Array

func get_next_position(current_position: Vector2i, target_position: Vector2i, pop_next: bool = true) -> Vector2i:
	if current_path.is_empty():
		find_path(current_position, target_position)
	
	var next_pos = current_path.front()
	if pop_next:
		current_path.pop_front()
	
	return next_pos


func find_path(current_position: Vector2i, target_position: Vector2i) -> Array:
	
	var to_visit: Array[Vector2i] = [current_position]
	var paths: Array[Array] = [[]] # Nested typed collections aren't supported 😔
	var visited: Array[Vector2i] = []
	
	var current_pos: Vector2i
	var current_path: Array
	while (not to_visit.is_empty()):
		# Get "best" tile to visit next
		var index_of_best: int = get_lowest_f_score(to_visit, paths, target_position) 
		
		current_pos = to_visit[index_of_best]
		current_path = paths[index_of_best]
		
		to_visit.erase(current_pos)
		paths.erase(current_path)
		
		if (visited.has(current_pos)):
			continue
		
		visited.append(current_pos)
		
		# We reached the target!
		if current_position == target_position:
			#print("Total tiles visited during pathfinding: ", visited.size())
			return current_path
		
		# Check if 4 adjacent tiles are valid
		# If so, add them to to_visit and paths
		for next_pos: Vector2i in get_adjacent_tiles(current_position):
			if (!visited.has(next_pos) && is_valid_tile(next_pos)): 
				to_visit.append(next_pos)
				var new_path = current_path.duplicate(true)
				new_path.append(next_pos)
				paths.append(new_path)
		
		if (visited.size() > 400):
			print("Total tiles visited during pathfinding: ", visited.size(), ", stopping pathfinding!")
			break
	
	return [] # could not find path

func is_valid_tile(map_pos: Vector2i) -> bool:
	
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	
	## Do not go on non-existent tiles - DEPRECATED
	#  Please do go on non-existent tiles
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_pos)
	if (tile_data == null):
		return true
	
	# Do not go on obstructive tiles
	var biome: int = tile_data.get_custom_data("biome")
	if obstructive_tiles.has(biome):
		return false
	
	# Do not go through structures
	if not ignore_structures:
		var structure_map: BuildingMap = get_tree().get_first_node_in_group("structure_map")
		if (structure_map.does_obstructive_structure_exist(map_pos)):
			return false
	
	# Do not go on other enemies
	if not ignore_entities:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if (enemy.grid_movement_component.current_position == map_pos):
				return false
	
	return true

# Returns the index of the tile with the lowest F score (f = dist_from_start + approx_dist_to_end)
func get_lowest_f_score(to_visit: Array[Vector2i], paths: Array[Array], target_pos: Vector2i) -> int:
	
	var lowest_f_score: float = INF;
	var best_index: int = -1
	
	for i in range(0, paths.size() - 1):
		var g_score: int = paths[i].size(); # dist_from_start
		
		var map_pos = paths[i].back()
		var h_score: float = Vector2(map_pos - target_pos).length(); # approx_dist_to_end
		
		var f_score = g_score + (h_score * 2) # Value approx_dist_to_end more than dist_from_start
		
		if (f_score < lowest_f_score):
			lowest_f_score = f_score
			best_index = i
	
	return best_index

func get_adjacent_tiles(pos: Vector2i) -> Array[Vector2i]:
	var right_tile = pos + Vector2i(1, 0)
	var left_tile = pos + Vector2i(-1, 0)
	var top_tile = pos + Vector2i(0, -1)
	var bottom_tile = pos + Vector2i(0, 1)
	
	return [right_tile, left_tile, top_tile, bottom_tile]
