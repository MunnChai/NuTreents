class_name TweeArrowHeightComponent
extends Node

## Sets the arrow height according to the life stage of the tree

@export var visual_arrow: VisualArrowComponent
@export var twee: TweeBehaviourComponent

func _ready() -> void:
	twee.grew_up.connect(_on_grew_up)
	
	if twee.is_large:
		visual_arrow.arrow_height = CursorWoodenArrow.ArrowHeight.HIGH
	else:
		visual_arrow.arrow_height = CursorWoodenArrow.ArrowHeight.MEDIUM

func _on_grew_up() -> void:
	visual_arrow.arrow_height = CursorWoodenArrow.ArrowHeight.HIGH
