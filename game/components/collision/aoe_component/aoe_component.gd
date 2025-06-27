class_name AoeComponent
extends HitboxComponent

@export var range: float

func explode() -> void:
	var collision_shape = $CollisionShape2D
	var circle_shape = collision_shape.shape as CircleShape2D
	circle_shape.radius = range
