class_name ObstructionComponent
extends Node2D

@export var is_obstructing: bool = true

## NEW: Add a verb override for UI tooltips.
## If this string is not empty, it will be used instead of "destroy".
## Example: "Un-petrify", "Clear", "Restore"
@export var verb_override: String = ""

func disable_obstruction() -> void:
	is_obstructing = false

func enable_obstruction() -> void:
	is_obstructing = true
