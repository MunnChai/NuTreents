class_name Enemy
extends Node

const MOVE_DURATION: float = 0.25

@export_group("Enemy Stats")
@export var health: int
@export var attack_damage: int
@export var attack_range: int
@export var move_speed: int

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

var map_position: Vector2i



# Pathfinding variables
var target_tree: Twee 
var current_path: Array

# Movement variables
var movement_cooldown: float

func _ready() -> void:
	init()

func init():
	target_tree = get_nearest_tree()
	
	if (target_tree != null):
		current_path = find_path_to_tree(target_tree)


func _process(delta: float) -> void:
	if (target_tree):
		update_movement(delta)



func update_movement(delta: float) -> void:
	if (movement_cooldown > 0):
		movement_cooldown -= delta
		return
	
	move_along_path()
	
	movement_cooldown = move_speed

# Returns true if it successfully moved, false if it has reached its destination
func move_along_path() -> bool:
	if (current_path.size() == 0):
		return false
	
	var next_tile: Vector2i = current_path.pop_front()
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	var global_pos: Vector2 = terrain_map.map_to_local(next_tile)
	
	# Hard coded for now
	var direction: Vector2i = next_tile - map_position
	match (direction):
		Vector2i.UP:
			sprite_2d.flip_h = true
		Vector2i.DOWN:
			sprite_2d.flip_h = true
		Vector2i.LEFT:
			sprite_2d.flip_h = false
		Vector2i.RIGHT:
			sprite_2d.flip_h = false
	
	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.set_ease(Tween.EASE_IN_OUT)
	pos_tween.set_trans(Tween.TRANS_CUBIC)
	pos_tween.tween_property(self, "position", global_pos, MOVE_DURATION)
	
	var offset_tween: Tween = get_tree().create_tween()
	offset_tween.set_ease(Tween.EASE_IN_OUT)
	offset_tween.set_trans(Tween.TRANS_CUBIC)
	offset_tween.tween_property(sprite_2d, "position:y", -20, MOVE_DURATION / 2)
	offset_tween.tween_property(sprite_2d, "position:y", -16, MOVE_DURATION / 2)
	
	map_position = next_tile
	
	return true











#
# Pathfinding stuff
#

# Uses A-Star to find the nearest viable path to the target_tree
func find_path_to_tree(tree: Twee) -> Array:
	
	var target_pos: Vector2i = tree.pos
	
	var to_visit: Array[Vector2i] = [map_position]
	var paths: Array[Array] = [[]] # Nested typed collections aren't supported 😔
	var visited: Array[Vector2i] = []
	
	var current_pos: Vector2i
	var current_path: Array
	while (not to_visit.is_empty()):
		# Get "best" tile to visit next
		var index_of_best: int = get_lowest_f_score(to_visit, paths, target_pos) 
		
		current_pos = to_visit[index_of_best]
		current_path = paths[index_of_best]
		
		to_visit.erase(current_pos)
		paths.erase(current_path)
		
		if (visited.has(current_pos)):
			continue
		
		visited.append(current_pos)
		
		# We reached the target!
		if (get_taxicab_distance(current_pos, target_pos) <= attack_range):
			print("Total tiles visited during enemy pathfinding: ", visited.size())
			return current_path
		
		# Check if 4 adjacent tiles are valid
		# If so, add them to to_visit and paths
		for next_pos: Vector2i in get_adjacent_tiles(current_pos):
			if (!visited.has(next_pos) && is_valid_tile(next_pos)): 
				to_visit.append(next_pos)
				var new_path = current_path.duplicate(true)
				new_path.append(next_pos)
				paths.append(new_path)
	
	return [] # could not find path


# Munn: If different enemies can traverse different tiles, then this should be changed.
func is_valid_tile(map_pos: Vector2i) -> bool:
	
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	
	# Do not go on non-existent tiles
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_pos)
	if (tile_data == null):
		return false
	
	# Do not go on Water
	var biome: int = tile_data.get_custom_data("biome")
	if (biome == 3): # WARNING: HARD CODED, DOES NOT USE ENUMS!
		return false
	
	# Do not go through structures
	var structure_map: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	if (structure_map.tile_scene_map.has(map_pos)):
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






# Returns nearest tree to current pos, using Taxicab Distance 
func get_nearest_tree() -> Twee:
	var tree_map: Dictionary[Vector2i, Twee] = TreeManager.get_tree_map()
	
	if (tree_map.is_empty()):
		return null
	
	var nearest_tree: Twee = null
	var nearest_dist: float = INF
	for key in tree_map:
		var tree: Twee = tree_map[key]
		
		var dist = get_taxicab_distance(tree.pos, map_position)
		if (dist < nearest_dist):
			nearest_tree = tree
			nearest_dist = dist
	
	return nearest_tree

func get_taxicab_distance(pos_i: Vector2i, pos_j: Vector2i) -> int:
	return abs(pos_i.x - pos_j.x) + abs(pos_i.y - pos_j.y)

func array_has(array: Array[Vector2i], what: Vector2i) -> bool:
	
	for thing: Vector2i in array:
		if (is_zero_approx(thing.distance_to(what))):
			return true
	
	return false
