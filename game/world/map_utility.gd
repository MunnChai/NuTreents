extends Node

#region TileInfo
func tile_has_structure(map_pos: Vector2i) -> bool:
	var structure_map: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	if (structure_map.does_obstructive_structure_exist(map_pos)):
		return true
	
	return false

func tile_has_enemy(map_pos: Vector2i) -> bool:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var grid_position_component: GridPositionComponent = Components.get_component(enemy, GridPositionComponent)
		if grid_position_component.get_pos() == map_pos:
			return true
	
	return false

func is_tile_accessible(map_position: Vector2i) -> bool:
	var surrounding_directions := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for direction in surrounding_directions:
		var true_position = map_position + direction
		
		var is_structure_obstructive = Global.structure_map.does_obstructive_structure_exist(true_position)
		var is_enemy_obstructive = EnemyManager.instance.get_enemy_at(true_position) != null
		
		if (not is_structure_obstructive) and (not is_enemy_obstructive):
			return true
	
	return false
#endregion


#region TileGetters
func get_entity_at(map_pos: Vector2i) -> Node2D:
	# Check structures
	var structure_map: BuildingMap = Global.structure_map
	var structure = structure_map.get_building_node(map_pos)
	if structure != null:
		return structure
	
	# Check enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var grid_position_component = Components.get_component(enemy, GridPositionComponent)
		if grid_position_component.get_pos() == map_pos:
			return enemy
	
	return null

func get_structure_at(map_pos: Vector2i) -> Node2D:
	return Global.structure_map.get_building_node(map_pos)

func get_adjacent_tiles(pos: Vector2i) -> Array[Vector2i]:
	var right_tile = pos + Vector2i(1, 0)
	var left_tile = pos + Vector2i(-1, 0)
	var top_tile = pos + Vector2i(0, -1)
	var bottom_tile = pos + Vector2i(0, 1)
	
	return [right_tile, left_tile, top_tile, bottom_tile]
#endregion


func get_taxicab_distance(pos_a: Vector2i, pos_b: Vector2i) -> int:
	return abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y)

func map_to_global(map_coords: Vector2i) -> Vector2:
	return Global.terrain_map.map_to_local(map_coords)
