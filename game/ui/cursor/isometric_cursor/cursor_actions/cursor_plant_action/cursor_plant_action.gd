class_name CursorPlantAction
extends CursorAction

## The PRIMARY ACTION taken by the Cursor

## Perform LEFT MOUSE BUTTON action
## - Planting trees on empty/valid tiles
func execute(cursor: IsometricCursor) -> void:
	var p: Vector2i = cursor.iso_position
	var terrain_map := Global.terrain_map
	var structure_map := Global.structure_map
	
	var has_selected_tree := TreeMenu.instance.is_selecting_tree
	var type: Global.TreeType = TreeMenu.instance.get_currently_selected_tree_type() 
	var tree_stat = TreeRegistry.get_twee_stat(type)
	
	var flag := cursor.get_hover_flag()
	
	## EARLY TERMINATIONS
	match flag:
		IsometricCursor.HoverFlag.VOID:
			return
		IsometricCursor.HoverFlag.OBSCURED:
			return
		IsometricCursor.HoverFlag.TOO_FAR_AWAY:
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup(tr(&"WARN_TOO_FAR_AWAY"), structure_map.map_to_local(p))
			return
		IsometricCursor.HoverFlag.OCCUPIED:
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup(tr(&"WARN_OCCUPIED"), structure_map.map_to_local(p), Color("ffb561"))
			return
		IsometricCursor.HoverFlag.NOT_FERTILE:
			SfxManager.play_sound_effect("ui_fail")
			PopupManager.create_popup(tr(&"WARN_NOT_FERTILE"), structure_map.map_to_local(p))
			return
		IsometricCursor.HoverFlag.OK_FOR_PLANTING:
			pass
		_:
			pass
	
	## OK, SO WE KNOW THAT THIS TILE IS FERTILE
	 
	## COST CHECK
	if !TreeManager.enough_n(tree_stat.cost_to_purchase):
		SfxManager.play_sound_effect("ui_fail")
		PopupManager.create_popup(tr(&"WARN_NOT_ENOUGH_NUTREENTS"), structure_map.map_to_local(p))
		return
	
	## FINAL CHECKS DEPENDING ON TYPE OF TREE
	## Terminate early if they fail
	## Assume visual indication of failure is handled by respective functions
	var tree := try_plant_tree(type, p)
	
	if tree: ## SUCCESS!
		var biome := terrain_map.get_tile_biome(p)
		print(biome)
		match biome:
			TerrainMap.TileType.SAND:
				SoundManager.play_oneshot(&"tree_plant_desert", structure_map.map_to_local(p))
			TerrainMap.TileType.SNOW:
				SoundManager.play_oneshot(&"tree_plant_snow", structure_map.map_to_local(p))
			_:
				SoundManager.play_oneshot(&"tree_plant", structure_map.map_to_local(p))

## Returns the tree on success
## null otherwise
func try_plant_tree(type: Global.TreeType, p: Vector2i) -> Node2D:
	## TILE CHECKING
	var structure_map := Global.structure_map
	match type:
		Global.TreeType.TECH_TREE: ## Tech Trees must be planted on Factory Remains
			var can_plant := true
			if not structure_map.tile_scene_map.has(p):
				can_plant = false
			elif not Components.has_component(structure_map.tile_scene_map[p], FactoryRemainsBehaviourComponent):
				can_plant = false
			
			if not can_plant:
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup(tr(&"WARN_NEED_FACTORY_REMAINS"), structure_map.map_to_local(p), Color("6be1e3"))
				return null
			else:
				PopupManager.create_popup(tr(&"SUCCESS_TECH_TREE_PLANTED"), structure_map.map_to_local(p), Color("6be1e3"))
				
				var notification = Notification.new(&"cost", '[color=6be1e3]' + tr(&"NOTIF_TECH_TREE_PLANTED"), { "priority": 1, "time_remaining": 3.0 });
				NotificationLog.instance.add_notification(notification)
		_: ## All other trees cannot be planted on Factory Remains
			if structure_map.tile_scene_map.has(p) and Components.has_component(structure_map.tile_scene_map[p], FactoryRemainsBehaviourComponent):
				SfxManager.play_sound_effect("ui_fail")
				PopupManager.create_popup(tr(&"WARN_NEED_NOT_FACTORY_REMAINS"), structure_map.map_to_local(p), Color("6be1e3"))
				return null
	
	## OK, so we know that the tree can be planted on this tile
	
	## CLEAR PLANTING LOCATION
	structure_map.remove_structure(p) ## Remove anything at that structure location...
	
	## PLACE NEW TREE
	var tree: Node2D = TreeRegistry.get_new_twee(type) ## We got the new tree
	TreeManager.place_tree(tree, p) ## And place it!
	
	## COST CONSUMPTION
	var tree_stat_component: TweeStatComponent = Components.get_component(tree, TweeStatComponent)
	TreeManager.consume_n(tree_stat_component.stat_resource.cost_to_purchase)
	
	return tree
