class_name BuildingMap
extends TileMapLayer

const SOURCE_ID: int = 1

var tile_scene_map: Dictionary[Vector2i, Node2D]
var non_decor_map: Dictionary[Vector2i, Node2D]

const COST_TO_REMOVE_CITY_TILE: int = 100
const COST_TO_REMOVE_ROAD_TILE: int = 250

func _ready() -> void:
	#add_to_group("structure_map")
	y_sort_enabled = true

func add_structure(map_coords: Vector2i, structure: Node2D, replace_existing: bool = false) -> bool:
	if not structure:
		return false

	if replace_existing:
		remove_structure(map_coords)
	else:
		if tile_scene_map.has(map_coords):
			# Check if it is a decor structure
			var curr_structure: Node2D = tile_scene_map[map_coords]
			if Components.has_component(curr_structure, ObstructionComponent): # Don't build on obstructive tiles
				structure.queue_free()
				return false
			# Otherwise, destroy the decor and continue
			remove_structure(map_coords)
	
	if Components.has_component(structure, FogRevealerComponent):
		Global.fog_map.remove_fog_around(map_coords)
	
	structure.position = map_to_local(map_coords)
	
	if Components.has_component(structure, ObstructionComponent):
		non_decor_map.set(map_coords, structure)
	
	tile_scene_map[map_coords] = structure
	if structure.get_parent() == null:
		add_child(structure)
		
		if Components.has_component(structure, GridPositionComponent):
			var position_component = Components.get_component(structure, GridPositionComponent)
			if position_component.occupied_positions.is_empty():
				position_component.init_pos(map_coords)
	return true

# Remove the node at the given map coordinates
# Returns true upon success, false if there is no node at the map coords
func remove_structure(map_coords: Vector2i) -> bool:
	if (!tile_scene_map.has(map_coords)):
		return false
	
	var object: Node2D = tile_scene_map[map_coords]
	
	# Munn: kinda temp fix? twees handle freeing themselves, so we only need to free stuff like 
	#       buildings, decor, etc.
	if not Components.has_component(object, TweeStatComponent):
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
	
	var object: Node2D = tile_scene_map[map_pos]
	
	if not Components.has_component(object, ObstructionComponent):
		return false
	
	var obstruction_component: ObstructionComponent = Components.get_component(object, ObstructionComponent)
	return obstruction_component.is_obstructing

const TWEEN_TIME = 0.2
const ADJACENT_TILE_REACH = 1
const TRANSPARENCY_ALPHA = 0.3
## Updates the transparencies of relevant tiles based on the given position
func update_transparencies_around(map_pos: Vector2i) -> void:
	var selected_structure = null
	if does_structure_exist(map_pos):
		selected_structure = tile_scene_map[map_pos]
	
	var adjacent_coords = []
	var adjacent_structures = []
	
	for x in range(map_pos.x, map_pos.x + ADJACENT_TILE_REACH + 1):
		for y in range(map_pos.y, map_pos.y + ADJACENT_TILE_REACH + 1):
			var adj_pos = Vector2i(x, y)
			if adj_pos == map_pos:
				continue
			if does_structure_exist(adj_pos):
				adjacent_coords.append(adj_pos)
				adjacent_structures.append(tile_scene_map[adj_pos])
	
	for key in tile_scene_map:
		var node: Node2D = tile_scene_map[key]
		
		if (not key in adjacent_coords and not node in adjacent_structures) or selected_structure == node:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(node, "modulate", Color(node.modulate, 1.0), TWEEN_TIME)
		else:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(node, "modulate", Color(node.modulate, TRANSPARENCY_ALPHA), TWEEN_TIME)


# Removes all structures including trees, except for the mother tree
func remove_all_structures() -> void:
	for pos in tile_scene_map.keys():
		if (!tile_scene_map.has(pos)):
			continue
		
		var structure = tile_scene_map[pos]
		remove_structure(pos)


func set_structures_from_data(data: Dictionary, remove_structures: bool = true) -> void:
	if remove_structures:
		remove_all_structures()
	
	for pos: Vector2i in data.keys():
		var save_resource: StructureDataResource = data[pos]
		
		var structure: Node2D = StructureRegistry.get_new_structure(save_resource.type)
		
		if add_structure(pos, structure):
			var structure_behaviour_component: StructureBehaviourComponent = Components.get_component(structure, StructureBehaviourComponent)
			structure_behaviour_component.apply_data_resource(save_resource)
