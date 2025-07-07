class_name CursorDestroyAction
extends CursorAction

## The DESTROY ACTION taken by the Cursor

## Perform RIGHT MOUSE BUTTON action
## - Removing trees
## - Destroying buildings
## - Destroying concrete
## - Un-petrifying trees
func execute(cursor: IsometricCursor) -> void:
	var p: Vector2i = cursor.iso_position
	var structure_map := Global.structure_map
	
	var hover_flag := cursor.get_hover_flag()
	match hover_flag:
		IsometricCursor.HoverFlag.VOID:
			return
		IsometricCursor.HoverFlag.OBSCURED:
			return
		IsometricCursor.HoverFlag.TOO_FAR_AWAY:
			return
		_:
			pass
	
	## We can reach and we aren't in the void
	
	## DESTROY STRUCTURE
	if structure_map.does_obstructive_structure_exist(p):
		var structure: Node2D = structure_map.tile_scene_map[p]
		try_destroy_structure(structure, p)
		return
	
	## OK, there was no structure...
	
	## DESTROY TILE
	try_destroy_tile(p)

#region DESTROY STRUCTURE

func try_destroy_structure(structure: Node2D, p: Vector2i) -> void:
	var structure_map := Global.structure_map
	
	## If building is tree, remove tree and return (unless it's the mother tree)
	if Components.has_component(structure, TweeStatComponent):
		try_destroy_tree(structure, p)
		return
	
	var entity = MapUtility.get_entity_at(p)
	## If building is not tree, but is destructable
	if Components.has_component(entity, DestructableComponent):
		try_destroy_destructable(entity, p)
		return
	
	## Huh... it's indestructable?
	SoundManager.play_oneshot(&"ui_fail", structure_map.map_to_local(p))
	PopupManager.create_popup(tr(&"WARN_INDESTRUCTIBLE"), structure_map.map_to_local(p))

func try_destroy_tree(tree: Node2D, p: Vector2i) -> void:
	var structure_map := Global.structure_map
	
	## MOTHER TREE CHECK PREVENTION
	if Components.get_component(tree, TweeStatComponent).type == Global.TreeType.MOTHER_TREE:
		PopupManager.create_popup(tr(&"WARN_MOTHER_TREE_REMOVAL"), structure_map.map_to_local(p))
		SoundManager.play_oneshot(&"ui_fail", structure_map.map_to_local(p))
		return
	
	var tree_behaviour_component: TweeBehaviourComponent = Components.get_component(tree, TweeBehaviourComponent)
	tree_behaviour_component.remove()
	PopupManager.create_popup(tr(&"SUCCESS_TREE_REMOVAL"), structure_map.map_to_local(p))

func try_destroy_destructable(structure: Node2D, p: Vector2i) -> void:
	var structure_map := Global.structure_map
	var destructable_component: DestructableComponent = Components.get_component(structure, DestructableComponent)
	
	## COST GATE
	var cost: float = destructable_component.get_cost()
	if not TreeManager.enough_n(cost):
		SoundManager.play_oneshot(&"ui_fail", structure_map.map_to_local(p))
		PopupManager.create_popup(tr(&"WARN_NOT_ENOUGH_NUTREENTS"), structure_map.map_to_local(p))
		return
	TreeManager.consume_n(cost)
	
	destructable_component.destroy()
	
	## TYPE CHECK for CONFIRMATION MESSAGE
	var structure_behaviour_component: StructureBehaviourComponent = Components.get_component(structure, StructureBehaviourComponent)
	match structure_behaviour_component.type:
		Global.StructureType.FACTORY:
			PopupManager.create_popup(tr(&"SUCCESS_FACTORY_REMOVAL"), structure_map.map_to_local(p))
		Global.StructureType.PETRIFIED_TREE: ## NOTE: TREE DE-PETRIFICATION / UN-PETRIFICATION IS REQUESTED HERE...
			#PopupManager.create_popup("De-Petrified!", structure_map.map_to_local(map_pos))
			var sprite_shatter_component: SpriteShatterComponent = Components.get_component(structure, SpriteShatterComponent, "", true)
			if sprite_shatter_component:
				await sprite_shatter_component.shatter_finished
		_:
			PopupManager.create_popup(tr(&"SUCCESS_BUILDING_REMOVAL"), structure_map.map_to_local(p))
	
	## JUICE
	SoundManager.play_oneshot(&"concrete_break", structure_map.map_to_local(p))

#endregion

#region DESTROY TILE

func try_destroy_tile(p: Vector2i) -> void:
	var structure_map := Global.structure_map
	var terrain_map := Global.terrain_map
	
	## IF THERE ARE NO STRUCTURES (except decor) ON THE TILE
	## If tile is city_tile/road_tile, replace tile with dirt tile if you have enough nutrients
	
	var tile_data = terrain_map.get_cell_tile_data(p)
	if not tile_data:
		return
	
	## BIOME CHECK
	var tile_type = tile_data.get_custom_data("biome")
	var cost := 0
	match tile_type:
		TerrainMap.TileType.CITY:
			cost = BuildingMap.COST_TO_REMOVE_CITY_TILE
		TerrainMap.TileType.ROAD:
			cost = BuildingMap.COST_TO_REMOVE_ROAD_TILE
		_:
			return ## We can't destroy other tiles!
	
	## COST CHECK
	if not TreeManager.enough_n(cost):
		SoundManager.play_oneshot(&"ui_fail", structure_map.map_to_local(p))
		PopupManager.create_popup(tr(&"WARN_NOT_ENOUGH_NUTREENTS"), structure_map.map_to_local(p))
		return
	TreeManager.consume_n(cost)
	
	terrain_map.set_cell_type(p, terrain_map.TileType.DIRT)
	
	## Check if decor exists on this spot
	## DECOR REMOVAL
	if structure_map.tile_scene_map.has(p) and not structure_map.does_obstructive_structure_exist(p):
		structure_map.remove_structure(p)
	
	## OK, now let's do the JUICE
	match tile_type:
		TerrainMap.TileType.CITY:
			SoundManager.play_oneshot(&"concrete_break", structure_map.map_to_local(p))
			PopupManager.create_popup(tr(&"SUCCESS_CONCRETE_REMOVAL"), structure_map.map_to_local(p))
		TerrainMap.TileType.ROAD:
			SoundManager.play_oneshot(&"concrete_break", structure_map.map_to_local(p))
			PopupManager.create_popup(tr(&"SUCCESS_ROAD_REMOVAL"), structure_map.map_to_local(p))

#endregion
