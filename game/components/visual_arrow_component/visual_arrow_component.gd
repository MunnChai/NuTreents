class_name VisualArrowComponent
extends Node2D

@export var arrow_height: CursorWoodenArrow.ArrowHeight
@export var custom_height: float
@export var show_arrow: bool = true

func get_arrow_cursor_height() -> CursorWoodenArrow.ArrowHeight:
	return arrow_height

func get_custom_height() -> float:
	return custom_height
