@tool
extends Sprite2D

@export var copy_from: Sprite2D

func _process(delta: float) -> void:
	hframes = copy_from.hframes
	vframes = copy_from.vframes
	frame = copy_from.frame
