extends Node2D

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
		modulate.a -= delta / lifetime
	
	if material is ShaderMaterial:
		material.set_shader_parameter("alpha", modulate.a)
	
	if modulate.a <= 0:
		queue_free()
