class_name CursorSelectAction
extends CursorAction

## Selects the currently hovered tile
func execute_primary_action(cursor: IsometricCursor) -> void:
	print("Select!")

func execute_secondary_action(cursor: IsometricCursor) -> void:
	pass
