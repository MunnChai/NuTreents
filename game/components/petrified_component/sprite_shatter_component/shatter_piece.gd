extends Node2D

@onready var polygon_2d: Polygon2D = $Polygon2D

const GRAVITY: float = 100

var velocity: Vector2
var lifetime: float

func _process(delta: float) -> void:
	_update_movement(delta)
	_update_alpha(delta)

func _update_movement(delta: float) -> void:
	if velocity.length() > 0:
		velocity.y += GRAVITY * delta
	
	position += velocity * delta

func _update_alpha(delta: float) -> void:
	if velocity.length() > 0:
		polygon_2d.modulate.a -= delta / lifetime
	
	if polygon_2d.material is ShaderMaterial:
		polygon_2d.material.set_shader_parameter("alpha", polygon_2d.modulate.a)
	
	if polygon_2d.modulate.a <= 0:
		queue_free()
		print("Freeing!")
