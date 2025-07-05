class_name CopyRect
extends NinePatchRect

@export var copy_from: Control

func _process(delta: float) -> void:
	size = MathUtil.decay(size, copy_from.size, 12.0, delta)
