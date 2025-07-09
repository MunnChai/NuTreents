class_name CursorAction
extends Node

## ABSTRACT BASE CLASS FOR AN ISOMETRIC CURSOR ACTION

## OVERRIDE THIS
## Execute this action
func execute_primary_action(cursor: IsometricCursor) -> void:
	print("WARNING! execute_primary_action called on CursorAction base class or a derived class that has not overridden its execute function")

func execute_secondary_action(cursor: IsometricCursor) -> void:
	print("WARNING! execute_secondary_action called on CursorAction base class or a derived class that has not overridden its execute function")

func enter(cursor: IsometricCursor) -> void:
	pass

func exit(cursor: IsometricCursor) -> void:
	pass
