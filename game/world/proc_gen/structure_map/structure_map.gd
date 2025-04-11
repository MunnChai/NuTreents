class_name BuildingMap
extends TileMapLayer

const SOURCE_ID: int = 1

var tile_scene_map: Dictionary[Vector2i, Node2D]

const COST_TO_REMOVE_CITY_TILE: int = 100
const COST_TO_REMOVE_ROAD_TILE: int = 250

func _ready() -> void:
	#add_to_group("structure_map")
	y_sort_enabled = true

func add_structure(map_coords: Vector2i, structure: Structure) -> bool:
	if (tile_scene_map.has(map_coords)):
		# Check if it is a decor structure
		var curr_structure: Structure = tile_scene_map[map_coords]
		if (!curr_structure.id.ends_with("decor")): # If it is not decor, you CANT BUILD HERE!
			return false
		# Otherwise, destroy the decor and continue
		remove_structure(map_coords)
	
	structure.position = map_to_local(map_coords)
	
	tile_scene_map[map_coords] = structure
	add_child(structure)
	return true

# Remove the node at the given map coordinates
# Returns true upon success, false if there is no node at the map coords
func remove_structure(map_coords: Vector2i) -> bool:
	if (!tile_scene_map.has(map_coords)):
		return false
	
	var object: Node2D = tile_scene_map[map_coords]
	
	# Munn: kinda temp fix? twees handle freeing themselves, so we only need to free stuff like 
	#       buildings, decor, etc.
	if (not object is Twee):
		remove_child(object)
	
	tile_scene_map.erase(map_coords)
	return true

func get_building_node(pos: Vector2i) -> Node2D:
	return tile_scene_map.get(pos)

func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_local_mouse_position()
	
	return mouse_screen_pos

# Returns true if this position has ANY structure on it
func does_structure_exist(map_pos: Vector2i) -> bool:
	return tile_scene_map.has(map_pos)

# Returns true if the position has an obstructive structure on it (structures that aren't decor)
func does_obstructive_structure_exist(map_pos: Vector2i) -> bool:
	if not does_structure_exist(map_pos):
		return false
	
	var object: Structure = tile_scene_map[map_pos]
	
	return !object.id.ends_with("decor")

const TWEEN_TIME = 0.2

## Updates the transparencies of relevant tiles based on the given position
func update_transparencies_around(map_pos: Vector2i) -> void:
	var adjacent_coords = []
	
	for x in range(map_pos.x, map_pos.x + 2):
		for y in range(map_pos.y, map_pos.y + 2):
			var adj_pos = Vector2i(x, y)
			if adj_pos == map_pos:
				continue
			if does_structure_exist(adj_pos):
				adjacent_coords.append(adj_pos)
	
	for key in tile_scene_map:
		var node: Node2D = tile_scene_map[key]
		
		if not key in adjacent_coords:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(node, "modulate", Color(node.modulate, 1.0), TWEEN_TIME)
		else:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(node, "modulate", Color(node.modulate, 0.4), TWEEN_TIME)
