class_name BuildingMap
extends TileMapLayer

const SOURCE_ID: int = 1

var tile_scene_map: Dictionary[Vector2i, Node2D]

func _ready() -> void:
	y_sort_enabled = true

func _input(_event: InputEvent) -> void:
	
	if (Input.is_action_pressed("lmb")):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		#add_cell(map_coords)
		add_default_tree(map_coords)
	
	if (Input.is_action_pressed("rmb")):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		remove_cell(map_coords)

# Add the node at the given map coordinates
# Returns true upon success, false if some node already exists at the map coords
func add_cell(map_coords: Vector2i) -> bool:
	if (tile_scene_map.has(map_coords)):
		return false
	
	var atlas_coords: Vector2i = Vector2i(0, 0)
	
	var scene_source: TileSetSource = tile_set.get_source(1)
	var scene: PackedScene = scene_source.get_scene_tile_scene(1)
	
	var object: Node2D = scene.instantiate()
	object.position = map_to_local(map_coords)
	
	tile_scene_map[map_coords] = object
	
	add_child(object)
	
	return true


# Remove the node at the given map coordinates
# Returns true upon success, false if there is no node at the map coords
func remove_cell(map_coords: Vector2i) -> bool:
	if (!tile_scene_map.has(map_coords)):
		return false
	
	var object: Node2D = tile_scene_map[map_coords]
	
	remove_child(object)
	
	tile_scene_map.erase(map_coords)
	TreeManager.remove_tree(map_coords)
	print(TreeManager.tree_map)
	return true

func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_local_mouse_position()
	
	return mouse_screen_pos


# Add a DefaultTree at given map coordinates
# Returns true upon success, false if some node already exists at the map coords
func add_default_tree(map_coords: Vector2i) -> bool:
	if (tile_scene_map.has(map_coords)):
		upgrade_cell(map_coords)
		return false
	
	var scene_source: TileSetSource = tile_set.get_source(2)
	var scene: PackedScene = scene_source.get_scene_tile_scene(1)
	
	var object: Node2D = scene.instantiate()
	object.position = map_to_local(map_coords)
	
	tile_scene_map[map_coords] = object
	TreeManager.add_tree(map_coords)
	add_child(object)
	print(TreeManager.tree_map)
	return true
	
func upgrade_cell(map_coords: Vector2i):
	var object: Node2D = tile_scene_map[map_coords]
	remove_child(object)
	tile_scene_map.erase(map_coords)
	
	
	var scene_source: TileSetSource = tile_set.get_source(2)
	var scene: PackedScene = scene_source.get_scene_tile_scene(2)
	
	var tree: Node2D = scene.instantiate()
	tree.position = map_to_local(map_coords)
	
	tile_scene_map[map_coords] = tree
	TreeManager.upgrade_tree(map_coords)
	add_child(tree)
	print(TreeManager.tree_map)
	return
