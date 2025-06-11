class_name PathfindingComponent
extends Node2D

@export var obstructive_tiles: Array[TerrainMap.TileType]
@export var ignore_structures: bool
@export var ignore_entities: bool

var current_path: Array = []

func get_next_position(pop_next: bool = false):
	if current_path.is_empty():
		return null
	
	var next_pos = current_path.front()
	if pop_next:
		current_path.pop_front()
	
	return next_pos

func pop_next_position():
	current_path.pop_front()

# Returns a path from start_position to target_position, which includes those positions
# Sets current path to the path that is found
func find_path(start_position: Vector2i, target_position: Vector2i) -> Array:
	var to_visit: Array[Vector2i] = [start_position]
	var paths: Array[Array] = [[start_position]] # Nested typed collections aren't supported 😔
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
		if current_pos == target_position:
			print("Total tiles visited during pathfinding: ", visited.size())
			self.current_path = current_path
			return current_path
		
		# Check if 4 adjacent tiles are valid
		# If so, add them to to_visit and paths
		for next_pos: Vector2i in MapUtility.get_adjacent_tiles(current_pos):
			# OVERRIDE to ignore "obstructions" on the target position
			if next_pos == target_position:
				var new_path = current_path.duplicate(true)
				new_path.append(next_pos)
				self.current_path = new_path
				return new_path
			
			if (!visited.has(next_pos) && is_valid_tile(next_pos)): 
				to_visit.append(next_pos)
				var new_path = current_path.duplicate(true)
				new_path.append(next_pos)
				paths.append(new_path)
		
		if (visited.size() > 400):
			print("Total tiles visited during pathfinding: ", visited.size(), ", stopping pathfinding!")
			break
	
	print("Could not find path during pathfinding!")
	self.current_path = []
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
	if not ignore_structures and MapUtility.tile_has_structure(map_pos):
		return false
	
	# Do not go on other enemies
	if not ignore_entities and MapUtility.tile_has_entity(map_pos):
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

func has_path() -> bool:
	return not current_path.is_empty()



# Gets the closest valid position to the target_position, relative to the start_position
# Uses A-Star starting from the target position, then moving to the start position
func get_closest_valid_position(start_position: Vector2i, target_position: Vector2i) -> Vector2i:
	var to_visit: Array[Vector2i] = [target_position]
	var paths: Array[Array] = [[target_position]]
	var visited: Array[Vector2i] = []
	
	var current_pos: Vector2i
	var current_path: Array
	while (not to_visit.is_empty()):
		# Get "best" tile to visit next
		var index_of_best: int = get_lowest_f_score(to_visit, paths, start_position) 
		
		current_pos = to_visit[index_of_best]
		current_path = paths[index_of_best]
		
		if is_valid_tile(current_pos) or current_pos == start_position:
			return current_pos
		
		to_visit.erase(current_pos)
		paths.erase(current_path)
		
		if (visited.has(current_pos)):
			continue
		
		visited.append(current_pos)
		
		# Check if 4 adjacent tiles are valid
		# If so, add them to to_visit and paths
		for next_pos: Vector2i in MapUtility.get_adjacent_tiles(current_pos):
			if not visited.has(next_pos): 
				to_visit.append(next_pos)
				var new_path = current_path.duplicate(true)
				new_path.append(next_pos)
				paths.append(new_path)
		
		if (visited.size() > 400):
			print("Could not find best closest tile!")
			break
	
	return Vector2i.ZERO
