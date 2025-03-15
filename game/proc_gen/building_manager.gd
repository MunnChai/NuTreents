extends Node2D

@onready var highlight: Sprite2D = $Highlight
@onready var terrain_map: TerrainMap = $GroundLayer
@onready var building_map: BuildingMap = $BuildingLayer

func _process(_delta: float) -> void:
	update_highlight()
	
	update_adjacent_tile_transparencies()

func update_highlight() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var map_coords: Vector2i = terrain_map.local_to_map(mouse_pos)
	
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_coords)
	
	if (tile_data == null):
		highlight.visible = false
	else:
		highlight.visible = true
		highlight.position = terrain_map.map_to_local(map_coords)

func update_adjacent_tile_transparencies() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var map_coords: Vector2i = building_map.local_to_map(mouse_pos)
	
	for x in range(map_coords.x, map_coords.x + 2):
		for y in range(map_coords.y, map_coords.y + 2):
			var adjacent_map_coords = Vector2i(x, y)
			
			if (adjacent_map_coords == map_coords):
				continue
			
			if (!building_map.tile_scene_map.has(adjacent_map_coords)):
				continue
			
			#var node: Node2D = building_map.tile_scene_map[adjacent_map_coords]
			#
			#node.modulate.a = 1.0
