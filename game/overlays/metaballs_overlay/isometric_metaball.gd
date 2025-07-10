class_name IsometricMetaball
extends Sprite2D

var time := 0.0

var origin := Vector2.ZERO

func _process(delta: float) -> void:
	time += delta
	position = origin + Vector2(sin(time) * 2.0, sin(time) * 2.0)
