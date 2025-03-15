class_name BuildingMap
extends TileMapLayer

const SOURCE_ID: int = 1

var tile_scene_map: Dictionary[Vector2i, Node2D]

func _ready() -> void:
	y_sort_enabled = true

func _input(_event: InputEvent) -> void:
	
	if (Input.is_action_pressed("lmb")):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		add_cell(map_coords)
	
	if (Input.is_action_pressed("rmb")):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		remove_cell(map_coords)

func add_cell(map_coords: Vector2i) -> bool:
	var atlas_coords: Vector2i = Vector2i(0, 0)
	
	var scene_source: TileSetSource = tile_set.get_source(1)
	var scene: PackedScene = scene_source.get_scene_tile_scene(1)
	
	var object: Node2D = scene.instantiate()
	object.position = map_to_local(map_coords)
	
	tile_scene_map[map_coords] = object
	
	add_child(object)
	
	return true

func remove_cell(map_coords: Vector2i) -> bool:
	erase_cell(map_coords)
	return true

func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_local_mouse_position()
	
	return mouse_screen_pos
