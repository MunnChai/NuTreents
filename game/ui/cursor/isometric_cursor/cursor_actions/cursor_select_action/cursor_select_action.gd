class_name CursorSelectAction
extends CursorAction

## Selects the currently hovered tile
func execute_primary_action(cursor: IsometricCursor) -> void:
	var iso_position: Vector2i = cursor.iso_position
	
	## EARLY TERMINATIONS
	var flag = cursor.get_hover_flag(iso_position)
	match flag:
		IsometricCursor.HoverFlag.VOID:
			return
		IsometricCursor.HoverFlag.OBSCURED:
			return
		_:
			pass
	
	var entity: Node2D = MapUtility.get_entity_at(iso_position)
	if not entity:
		cursor.set_selected_entity(null)
		return
	
	if cursor.get_selected_entity() == entity:
		cursor.set_selected_entity(null)
		return
	
	var tooltip: TooltipIdentifierComponent = Components.get_component(entity, TooltipIdentifierComponent)
	if not tooltip:
		cursor.set_selected_entity(null)
		return
	
	cursor.set_selected_entity(entity)
	SoundManager.play_oneshot(&"ui_click", Global.structure_map.map_to_local(iso_position))


func execute_secondary_action(cursor: IsometricCursor) -> void:
	cursor.set_selected_entity(null)

func enter(cursor: IsometricCursor) -> void:
	pass

func exit(cursor: IsometricCursor) -> void:
	cursor.set_selected_entity(null)
