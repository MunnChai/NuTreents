class_name CursorSelectAction
extends CursorAction

## Selects the currently hovered tile
func execute_primary_action(cursor: IsometricCursor) -> void:
	var iso_position: Vector2i = cursor.iso_position
	
	var entity: Node2D = MapUtility.get_entity_at(iso_position)
	if entity:
		if cursor.get_selected_entity() != entity:
			cursor.set_selected_entity(entity)
			SoundManager.play_oneshot(&"ui_click", Global.structure_map.map_to_local(iso_position))
		else:
			cursor.set_selected_entity(null)
	else:
		cursor.set_selected_entity(null)

func execute_secondary_action(cursor: IsometricCursor) -> void:
	cursor.set_selected_entity(null)

func enter(cursor: IsometricCursor) -> void:
	pass

func exit(cursor: IsometricCursor) -> void:
	cursor.set_selected_entity(null)
