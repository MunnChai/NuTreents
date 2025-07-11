class_name VisualCursorDestroyState
extends VisualCursorState

var destructible_tiles_highlight: LargeModulationHighlight
var is_entered: bool = false

func _ready() -> void:
	call_deferred("_connect_destructible_tile_update")

func _connect_destructible_tile_update() -> void:
	Global.structure_map.structure_added.connect(_update_destructible_tiles.unbind(1))
	Global.structure_map.structure_removed.connect(_update_destructible_tiles.unbind(1))
	Global.terrain_map.changed.connect(_update_destructible_tiles)

## Get 2 new large modulation highlights, one for the plantable tiles, one for grid ranges
func enter(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	is_entered = true
	destructible_tiles_highlight = visual_cursor.get_large_highlight()
	_update_destructible_tiles()

func exit(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	visual_cursor.reset_highlight_pool()
	is_entered = false

## Change visual details based on what is highlighted...
func _update_visuals(cursor: IsometricCursor, visual_cursor: IsometricCursorVisual) -> void:
	var terrain_map = Global.terrain_map
	var structure_map = Global.structure_map
	var iso_position = cursor.iso_position
	
	## Highlight the tile at iso position
	visual_cursor.highlight_tile_at(iso_position)
	
	## Highlight destructible tiles
	highlight_destructible_tiles(cursor)
	
	var flag := cursor.get_hover_flag()
	
	## GENERAL HOVER CRITERIA
	match flag:
		IsometricCursor.HoverFlag.VOID:
			visual_cursor.disable()
		IsometricCursor.HoverFlag.TOO_FAR_AWAY, IsometricCursor.HoverFlag.OBSCURED, IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			visual_cursor.enable()
			visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
			visual_cursor.set_arrow_visible(false)
			visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.NOT_FERTILE: 
			if terrain_map.is_concrete(iso_position):
				visual_cursor.enable()
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_arrow_visible(true)
				visual_cursor.set_arrow_bobbing(true)
				match terrain_map.get_tile_biome(iso_position):
					TerrainMap.TileType.CITY:
						if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_CITY_TILE):
							visual_cursor.set_arrow_bobbing(false)
					TerrainMap.TileType.ROAD:
						if not TreeManager.enough_n(structure_map.COST_TO_REMOVE_ROAD_TILE):
							visual_cursor.set_arrow_bobbing(false)
		IsometricCursor.HoverFlag.OCCUPIED:
			visual_cursor.enable()
			visual_cursor.set_arrow_visible(true)
			if TreeManager.is_twee(iso_position): # can always destroy tree
				visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
				visual_cursor.set_arrow_bobbing(true)
			else:
				visual_cursor.enable()
				var building_node = structure_map.get_building_node(iso_position)
				var destructable: DestructableComponent = Components.get_component(building_node, DestructableComponent)
				if not destructable: # Non destructible obstructive entity 
					visual_cursor.enable()
					visual_cursor.set_highlight_modulate(IsometricCursorVisual.RED)
					visual_cursor.set_arrow_visible(false)
					visual_cursor.set_arrow_bobbing(false)
				else: # Destructible entity, check for nutreent cost
					if TreeManager.enough_n(destructable.get_cost()):
						visual_cursor.set_highlight_modulate(IsometricCursorVisual.BLUE)
						visual_cursor.set_arrow_visible(true)
						visual_cursor.set_arrow_bobbing(true)
					else:
						visual_cursor.set_highlight_modulate(IsometricCursorVisual.YELLOW)
						visual_cursor.set_arrow_visible(true)
						visual_cursor.set_arrow_bobbing(false)
		_:
			pass ## How did we get here?

var destructible_tiles: Array[Vector2i]
func highlight_destructible_tiles(cursor: IsometricCursor) -> void:
	destructible_tiles_highlight._reset_pool()
	
	destructible_tiles_highlight.highlight_tiles_at(destructible_tiles)
	destructible_tiles_highlight.set_color(IsometricCursorVisual.RED)

func _update_destructible_tiles() -> void:
	if not is_entered: # ONLY UPDATE WHEN IN THIS STATE
		return
	
	destructible_tiles.clear()
	var reachable_tiles: Array[Vector2i] = TreeManager.get_reachable_tree_placement_positions(true)
	for iso_pos: Vector2i in reachable_tiles:
		var structure: Node2D = Global.structure_map.get_building_node(iso_pos)
		var twee_behaviour: TweeBehaviourComponent = Components.get_component(structure, TweeBehaviourComponent)
		if twee_behaviour:
			if not twee_behaviour.is_removed:
				destructible_tiles.append(iso_pos)
				continue
		var destructible: DestructableComponent = Components.get_component(structure, DestructableComponent)
		if destructible:
			destructible_tiles.append(iso_pos)
			continue
