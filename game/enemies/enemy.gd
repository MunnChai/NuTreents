class_name Enemy
extends Node2D

const MOVE_DURATION: float = 0.5

@export var id: String

@export_group("Enemy Stats")
@export var max_health: int
@export var attack_damage: int
@export var attack_range: int
@export var move_speed: int

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

var current_health: float
var is_dead: bool = false

var map_position: Vector2i



# Pathfinding variables
var target_tree: Twee 
var current_path: Array

# Movement variables
var movement_cooldown: float

func _ready() -> void:
	init()
	sprite_2d.vframes = 4

func init():
	target_new_tree()
	add_to_group("enemies")
	current_health = max_health



func _process(delta: float) -> void:
	update_movement(delta)




func update_movement(delta: float) -> void:
	if (is_dead):
		return
	
	if (movement_cooldown > 0):
		movement_cooldown -= delta
		return
	
	do_action()
	
	movement_cooldown = move_speed

func do_action():
	# If the target tree doesn't exist
	if (!target_tree || target_tree.died):
		target_new_tree()
	
	# If there are no more trees, do nothing
	if (!target_tree || target_tree.died):
		return
	
	# If the target tree exists:
	var dist_to_tree = get_taxicab_distance(target_tree.pos, map_position)
	
	if (dist_to_tree <= attack_range):
		attack_tree()
	else:
		move_along_path()

func attack_tree():
	var direction: Vector2i = target_tree.pos - map_position
	face_direction(direction)
	
	var this_position = position
	
	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.set_ease(Tween.EASE_IN_OUT)
	pos_tween.set_trans(Tween.TRANS_CUBIC)
	pos_tween.tween_property(self, "position", target_tree.global_position, MOVE_DURATION / 2)
	pos_tween.tween_property(self, "position", this_position, MOVE_DURATION / 2)
	
	# Connect signals
	pos_tween.step_finished.connect(
		func(tween):
			deal_damage()
			
			# Disconnect signals
			for callback in pos_tween.step_finished.get_connections():
				pos_tween.step_finished.disconnect(callback["callable"])
	)
	
	var offset_tween: Tween = get_tree().create_tween()
	offset_tween.set_ease(Tween.EASE_IN_OUT)
	offset_tween.set_trans(Tween.TRANS_CUBIC)
	offset_tween.tween_property(sprite_2d, "position:y", -20, MOVE_DURATION / 4)
	offset_tween.tween_property(sprite_2d, "position:y", -16, MOVE_DURATION / 4)
	offset_tween.tween_property(sprite_2d, "position:y", -20, MOVE_DURATION / 4)
	offset_tween.tween_property(sprite_2d, "position:y", -16, MOVE_DURATION / 4)

# Returns true if it successfully moved, false if it has reached its destination
func move_along_path() -> bool:
	if (current_path.size() == 0):
		return false
	
	var next_tile: Vector2i = current_path.pop_front()
	if (!is_valid_tile(next_tile)):
		var new_tree = target_new_tree()
		if (!new_tree):
			return false
		
		if (current_path.size() == 0):
			return false
		
		next_tile = current_path.pop_front()
	
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	var global_pos: Vector2 = terrain_map.map_to_local(next_tile)
	
	# Hard coded for now
	var direction: Vector2i = next_tile - map_position
	face_direction(direction)
	
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

func deal_damage():
	if (!target_tree):
		return
	
	target_tree.take_damage(attack_damage)


func face_direction(direction: Vector2i) -> void:
	match (direction):
		Vector2i.UP:
			sprite_2d.flip_h = true
			animation_player.play("idle_backwards")
		Vector2i.DOWN:
			sprite_2d.flip_h = true
			animation_player.play("idle")
		Vector2i.LEFT:
			sprite_2d.flip_h = false
			animation_player.play("idle_backwards")
		Vector2i.RIGHT:
			sprite_2d.flip_h = false
			animation_player.play("idle")



func target_new_tree() -> Twee:
	var tree = get_nearest_tree()
	if (tree):
		target_tree = tree
		current_path = find_path_to_tree(target_tree)
	
	return tree

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
		
		if (visited.size() > 200):
			break
	
	return [] # could not find path


# Munn: If different enemies can traverse different tiles, then this should be changed.
func is_valid_tile(map_pos: Vector2i) -> bool:
	
	var terrain_map: TerrainMap = get_tree().get_first_node_in_group("terrain_map")
	
	## Do not go on non-existent tiles - DEPRECATED
	#  Please do go on non-existent tiles
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_pos)
	if (tile_data == null):
		return true
	
	# Do not go on Water
	var biome: int = tile_data.get_custom_data("biome")
	if (biome == 3): # WARNING: HARD CODED, DOES NOT USE ENUMS!
		return false
	
	# Do not go through structures
	var structure_map: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	if (structure_map.does_obstructive_structure_exist(map_pos)):
		return false
		
	
	# Do not go on other enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if (enemy.map_position == map_pos):
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
		if (tree.died):
			continue
		
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

func take_damage(damage: int):
	PopupManager.create_popup(str(damage), Global.structure_map.map_to_local(map_position))
	
	current_health -= damage
	
	if (current_health <= 0):
		die()
	else:
		if (animation_player.current_animation == "idle"):
			animation_player.play("hurt")
			animation_player.queue("idle")
		elif (animation_player.current_animation == "idle_backwards"):
			animation_player.play("hurt_backwards")
			animation_player.queue("idle_backwards")

func die():
	is_dead = true
	
	#play sound effect
	SfxManager.play_sound_effect("speedle_die")
	
	animation_player.play("death")
	animation_player.animation_finished.connect(
		func(animation_name):
			queue_free()
	)
