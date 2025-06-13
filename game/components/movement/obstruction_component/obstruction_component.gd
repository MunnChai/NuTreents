class_name ObstructionComponent
extends Node2D

@export var is_obstructing: bool = true

func disable_obstruction() -> void:
	is_obstructing = false

func enable_obstruction() -> void:
	is_obstructing = true
