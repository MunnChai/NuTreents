extends Node2D

func _ready() -> void:
	$AnimatedSprite.play()

func _on_animated_sprite_animation_finished() -> void:
	queue_free()
