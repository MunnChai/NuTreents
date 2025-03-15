extends TileMapLayer

const MAP_SIZE: Vector2i = Vector2i(50, 50)
const SOURCE_ID: int = 1


func _ready() -> void:
	generate_map()


func _input(event: InputEvent) -> void:
	
	if (event is InputEventMouseButton):
		var map_coords: Vector2i = local_to_map(get_mouse_coords())
		
		var source_id: int = 1
		var atlas_coords: Vector2i = Vector2i(0, 0)
		var alt_id: int = 0
		
		set_cell(map_coords, SOURCE_ID, atlas_coords, alt_id)

func get_mouse_coords() -> Vector2:
	var mouse_screen_pos: Vector2 = get_viewport().get_mouse_position()
	var mouse_local_pos: Vector2 = mouse_screen_pos - Vector2(get_viewport().size) / 2
	
	return mouse_local_pos


func generate_map() -> void:
	
	for x in range(-MAP_SIZE.x / 2, MAP_SIZE.x / 2):
		for y in range(-MAP_SIZE.y / 2, MAP_SIZE.y / 2):
			
			var map_coords: Vector2i = Vector2i(x ,y)
			var atlas_coords: Vector2i = Vector2i(0, 0)
			
			set_cell(map_coords, SOURCE_ID, atlas_coords, 0)
