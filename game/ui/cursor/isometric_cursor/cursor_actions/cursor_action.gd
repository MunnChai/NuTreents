class_name CursorAction
extends Node

## ABSTRACT BASE CLASS FOR AN ISOMETRIC CURSOR ACTION

## OVERRIDE THIS
## Execute this action
func execute(cursor: IsometricCursor) -> void:
	print("WARNING! execute called on CursorAction base class or a derived class that has not overridden its execute function")
