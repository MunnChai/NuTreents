extends Node
class_name tree_manager

@onready var fog_map: FogMap = get_tree().get_nodes_in_group("fog_map")[0]
@onready var structure_map: BuildingMap = get_tree().get_nodes_in_group("structure_map")[0]
@onready var terrain_map: TerrainMap = get_tree().get_nodes_in_group("terrain_map")[0]

# stores all trees
var tree_map: Dictionary[Vector2i, Node2D]
var total_water: int
var total_n: int
var total_sun: int

func _ready():
	total_water = 0
	total_n = 0
	total_sun = 0
	
	call_deferred("add_tree", 0, Constants.MAP_SIZE / 2, false)

# TODO: add resources checking

# add tree with given type at p
# TODO type: will add more types later, codes only use DefaultTree for now
# return: 0 -> successful, 1 -> unavailable space, 2-> insufficient resources
# 3 -> invalid/non-solid tile, 4 -> out of reach
func add_tree(type: int, p: Vector2i, enforce_reachable: bool = true) -> int:
	if (tree_map.has(p)):
		return 1
	if not terrain_map.is_fertile(p):
		return 3 
	if enforce_reachable and not is_reachable(p):
		return 4
	var tree = DefaultTree.new(0, p)
	tree_map[p] = tree
	# call structure_map to add it on screen
	var object: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	object.add_default_tree(p)
	
	fog_map.remove_fog_around(p)
	return 0


# upgrade the tree at given p
# return: 0 -> succesfful, 1 -> no tree at p, 2 -> insufficient resources
#         3 -> secondary tree exists at p
func upgrade_tree(p: Vector2i) -> int:
	if (!tree_map.has(p)):
		return 1
		
	var original_tree: DefaultTree = tree_map[p]
	if (original_tree.level == 2):
		return 3
		
	tree_map.erase(p)
	var new_tree: DefaultTree = original_tree.upgrade()
	tree_map[p] = new_tree
	original_tree.queue_free()
	
	var object: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	object.upgrade_cell(p)
	return 0


# remove the tree at given p; returns true if successful, false otherwise
func remove_tree(p: Vector2i) -> bool:
	if (!tree_map.has(p)):
		return false
	var tree = tree_map[p]
	tree_map.erase(p)
	tree.queue_free()
	var object: BuildingMap = get_tree().get_first_node_in_group("structure_map")
	object.remove_cell(p)
	return true

# function for testing, remove eventually
func print_trees():
	for key in tree_map:
		var tree: DefaultTree = tree_map[key]
		print(key, tree.storage)
	print()

func is_reachable(pos: Vector2i):
	return get_reachable_tree_placement_positions().has(pos)

func get_reachable_tree_placement_positions() -> Array[Vector2i]:
	var allowed_positions: Array[Vector2i] = []
	var occupied_position: Array[Vector2i] = []
	
	for pos in tree_map.keys():
		occupied_position.append(pos)
		var tree: Twee = tree_map.get(pos)
		for offset in tree.get_reachable_offsets():
			allowed_positions.append(pos + offset)
	
	var final_allowed_positions: Array[Vector2i] = []
	for pos in allowed_positions:
		if not occupied_position.has(pos):
			final_allowed_positions.append(pos)
	
	return final_allowed_positions
