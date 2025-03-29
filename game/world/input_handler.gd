class_name InputHandler
extends Node

func _unhandled_input(event: InputEvent) -> void:
	if (Global.game_state != Global.GameState.PLAYING):
		return
	
	if (TreeManager.is_mother_dead()):
		# if mother died
		return
	if (Input.is_action_pressed("lmb")):
		var map_coords: Vector2i = Global.structure_map.local_to_map(Global.structure_map.get_mouse_coords())
		
		TreeManager.add_tree(TreeManager.selected_tree_species, map_coords) 
	
	if (Input.is_action_just_pressed("rmb")):
		var map_coords: Vector2i = Global.structure_map.local_to_map(Global.structure_map.get_mouse_coords())
		
		TreeManager.handle_right_click(map_coords)
	
	update_highlight()
	update_adjacent_tile_transparencies()

func _process(delta: float) -> void:
	pass

# Moves the tile highlight sprite to the correct position
func update_highlight() -> void:
	var terrain_map = Global.terrain_map
	var tile_manager: TileManager = get_tree().get_first_node_in_group("tile_manager")
	var mouse_pos: Vector2 = terrain_map.get_local_mouse_position()
	var map_coords: Vector2i = terrain_map.local_to_map(mouse_pos)
	
	var tile_data: TileData = terrain_map.get_cell_tile_data(map_coords)
	
	# DON'T HIGHLIGHT OUTSIDE MAP
	if terrain_map.is_void(map_coords):
		tile_manager.highlight.visible = false
	else:
		tile_manager.highlight.visible = true
		tile_manager.highlight.position = terrain_map.map_to_local(map_coords)

	if terrain_map.is_fertile(map_coords) and TreeManager.is_reachable(map_coords):
		tile_manager.highlight.modulate = Color("3fd7ff81") ## BLUE
		tile_manager.cursor.set_low()
		tile_manager.cursor.enable()
	elif TreeManager.is_occupied(map_coords):
		## There is a tree here...
		tile_manager.highlight.modulate = Color("ca910081") ## YELLOW
		if TreeManager.is_large(map_coords):
			tile_manager.cursor.set_high()
		else:
			tile_manager.cursor.set_medium()
		tile_manager.cursor.enable()
	else:
		tile_manager.highlight.modulate = Color("ff578681") ## RED
		var building_node: Node2D = Global.structure_map.get_building_node(map_coords)
		if not TreeManager.is_reachable(map_coords):
			## Cannot place on this tile
			tile_manager.cursor.disable()
		elif terrain_map.get_tile_biome(map_coords) == TerrainMap.TILE_TYPE.CITY or terrain_map.get_tile_biome(map_coords) == TerrainMap.TILE_TYPE.ROAD:
			tile_manager.cursor.set_low()
			if building_node:
				if building_node.get_id() == "city_building":
					tile_manager.cursor.set_high_play()
					tile_manager.cursor.play()
				elif building_node.get_id() == "factory":
					tile_manager.cursor.set_medium_play()
			tile_manager.cursor.enable()
		else:
			## Cannot place on this tile
			tile_manager.cursor.disable()
	
	# DETECT WHAT IS HIGHLIGHTED
	detect_highlighted_objects(map_coords)

func detect_highlighted_objects(pos: Vector2i) -> void:
	var terrain_map = Global.terrain_map
	var building_map = Global.structure_map
	var tile_type: TerrainMap.TILE_TYPE = terrain_map.get_tile_biome(pos)
	var building_node: Node2D = building_map.get_building_node(pos)
	var enemies: Array[Enemy] = EnemyManager.current_enemies
	
	# Munn: shouldn't actually be too performance heavy, since we should have like < 50 enemies at a time
	var is_hovering_enemy: bool = false
	var hovered_enemy: Enemy
	for enemy: Enemy in enemies:
		if (!enemy):
			continue
		if (enemy.map_position == pos):
			hovered_enemy = enemy
			is_hovering_enemy = true
			break
	
	if (is_hovering_enemy):
		InfoBox.get_instance().show_content_for(pos, hovered_enemy.id, tile_type)
	elif building_node != null:
		InfoBox.get_instance().show_content_for(pos, building_node.get_id(), tile_type)
	else:
		InfoBox.get_instance().show_content_for(pos, "no_building", tile_type)

const TWEEN_TIME = 0.2

# Updates the building map to make buildings in front of the currently hovered tile transparent
func update_adjacent_tile_transparencies() -> void:
	var building_map = Global.structure_map
	var mouse_pos: Vector2 = building_map.get_local_mouse_position()
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
