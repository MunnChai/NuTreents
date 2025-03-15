extends Node2D

@onready var highlight: Sprite2D = $Highlight
@onready var terrain_map: TerrainMap = $GroundLayer

func _process(delta: float) -> void:
	update_highlight()

func update_highlight() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var map_coords: Vector2i = terrain_map.local_to_map(mouse_pos)
	
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_coords)
	
	if (tile_data == null):
		highlight.visible = false
	else:
		highlight.visible = true
		highlight.position = terrain_map.map_to_local(map_coords)
