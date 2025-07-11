class_name BuildingMap
extends TileMapLayer

const SOURCE_ID: int = 1

var tile_scene_map: Dictionary[Vector2i, Node2D]
var non_decor_map: Dictionary[Vector2i, Node2D]

const COST_TO_REMOVE_CITY_TILE: int = 100
const COST_TO_REMOVE_ROAD_TILE: int = 250

signal structure_added(node: Node2D)
signal structure_removed(node: Node2D)

func _ready() -> void:
	#add_to_group("structure_map")
	y_sort_enabled = true

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("debug_button"):
		#add_structure(local_to_map(get_mouse_coords()), StructureRegistry.get_new_structure(Global.StructureType.PETRIFIED_TREE))

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
	
	var fog_revealer_component: FogRevealerComponent = Components.get_component(structure, FogRevealerComponent)
	if fog_revealer_component:
		Global.fog_map.remove_fog_around(map_coords, fog_revealer_component)
	
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
	
	structure_added.emit(structure)
	
	return true

# Remove the node at the given map coordinates
# Returns true upon success, false if there is no node at the map coords
func remove_structure(map_coords: Vector2i) -> bool:
	if (!tile_scene_map.has(map_coords)):
		return false
	
	var object: Node2D = tile_scene_map[map_coords]
	
	structure_removed.emit(object)
	
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
func update_transparencies_around(old_pos: Vector2i, new_pos: Vector2i) -> void:
	var selected_structure = null
	if does_structure_exist(new_pos):
		selected_structure = tile_scene_map[new_pos]
	
	var adjacent_coords = []
	var adjacent_structures = []
	var offsets = [
		Vector2i.ZERO,
		Vector2i.DOWN, Vector2i.RIGHT, Vector2i.DOWN + Vector2i.RIGHT,
		2 * Vector2i.DOWN + 1 * Vector2i.RIGHT,
		1 * Vector2i.DOWN + 2 * Vector2i.RIGHT,
		2 * Vector2i.DOWN + 2 * Vector2i.RIGHT,
	]
	
	var old_positions: Array[Vector2i] = []
	var new_positions: Array[Vector2i] = []
	
	# Get new positions
	for offset in offsets:
		var pos: Vector2i = new_pos + offset
		new_positions.append(pos)
	
	# Get old positions
	for offset in offsets:
		var pos: Vector2i = old_pos + offset
		if pos in new_positions:
			continue
		
		old_positions.append(pos)
	
	for pos: Vector2i in old_positions:
		var node: Node2D = get_building_node(pos)
		if is_instance_valid(node):
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(node, "modulate", Color(node.modulate, 1.0), TWEEN_TIME)
	
	for pos: Vector2i in new_positions:
		var node: Node2D = get_building_node(pos)
		if not is_instance_valid(node):
			continue
		if node == selected_structure:
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


const PETRIFIED_DECOR_COMPONENT = preload("res://components/petrified_component/petrified_decor_component/petrified_decor_component.tscn")
func set_structures_from_data(data: Dictionary, remove_structures: bool = true) -> void:
	if remove_structures:
		remove_all_structures()
	
	for pos: Vector2i in data.keys():
		var save_resource: StructureDataResource = data[pos]
		
		var structure: Node2D = StructureRegistry.get_new_structure(save_resource.type)
		
		if add_structure(pos, structure):
			var structure_behaviour_component: StructureBehaviourComponent = Components.get_component(structure, StructureBehaviourComponent)
			structure_behaviour_component.apply_data_resource(save_resource)
			
			if save_resource.is_petrified:
				if structure_behaviour_component.type == Global.StructureType.DECOR:
					var petrified_decor_component = PETRIFIED_DECOR_COMPONENT.instantiate()
					structure.add_child(petrified_decor_component)
					petrified_decor_component.petrify(true)
