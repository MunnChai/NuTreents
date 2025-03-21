extends Node2D

@onready var highlight: Sprite2D = $Highlight
@onready var cursor: AnimatedSprite2D = $Cursor
@onready var terrain_map: TerrainMap = $GroundLayer
@onready var building_map: BuildingMap = $BuildingLayer

func _process(_delta: float) -> void:
	update_highlight()
	
	update_adjacent_tile_transparencies()

# Moves the tile highlight sprite to the correct position
func update_highlight() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var map_coords: Vector2i = terrain_map.local_to_map(mouse_pos)
	
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_coords)
	
	# DON'T HIGHLIGHT OUTSIDE MAP
	if terrain_map.is_void(map_coords):
		highlight.visible = false
	else:
		highlight.visible = true
		highlight.position = terrain_map.map_to_local(map_coords)

	if terrain_map.is_fertile(map_coords) and TreeManager.is_reachable(map_coords):
		highlight.modulate = Color("3fd7ff81") ## BLUE
		cursor.set_low()
		cursor.enable()
	elif TreeManager.is_occupied(map_coords):
		## There is a tree here...
		highlight.modulate = Color("ca910081") ## YELLOW
		if TreeManager.is_large(map_coords):
			cursor.set_high()
		else:
			cursor.set_medium()
		cursor.enable()
	else:
		## Cannot place on this tile
		highlight.modulate = Color("ff578681") ## RED
		cursor.disable()
	
	# DETECT WHAT IS HIGHLIGHTED
	#detect_highlighted_objects(map_coords)

func detect_highlighted_objects(pos: Vector2i) -> void:
	var tile_type: TerrainMap.TILE_TYPE = terrain_map.get_tile_biome(pos)
	var building_node: Node2D = building_map.get_building_node(pos)
	
	print(tile_type)
	if building_node != null:
		print(building_node.get_id())

const TWEEN_TIME = 0.2

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies() -> void:
	var mouse_pos: Vector2 = get_local_mouse_position()
	var map_coords: Vector2i = building_map.local_to_map(mouse_pos)
	
	for key in building_map.tile_scene_map:
		var node: Node2D = building_map.tile_scene_map[key]
		
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(node, "modulate", Color(node.modulate, 1.0), TWEEN_TIME)
		#node.modulate.a = 1.0
	
	for x in range(map_coords.x, map_coords.x + 2):
		for y in range(map_coords.y, map_coords.y + 2):
			var adjacent_map_coords = Vector2i(x, y)
			
			if (adjacent_map_coords == map_coords):
				continue
			
			if (!building_map.tile_scene_map.has(adjacent_map_coords)):
				continue
			
			var node: Node2D = building_map.tile_scene_map[adjacent_map_coords]
			
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(node, "modulate", Color(node.modulate, 0.05), TWEEN_TIME)
			#node.modulate.a = 0.5
