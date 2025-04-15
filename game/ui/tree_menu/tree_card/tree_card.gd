class_name TreeCard
extends Control

@export var tree_image: Texture2D

@onready var start_position: Vector2 = $CardRect.position

var is_highlighted = false

func _ready() -> void:
	$CardRect/ImageRect.texture = tree_image

func _on_mouse_entered() -> void:
	#$CardRect.global_position = start_position + Vector2.UP * 5.0
	#$CardRect.modulate = Color.RED
	is_highlighted = true

func _on_mouse_exited() -> void:
	#$CardRect.global_position = start_position
	#$CardRect.modulate = Color.WHITE
	is_highlighted = false

func _process(delta: float) -> void:
	if is_highlighted:
		$CardRect.position = start_position + Vector2.UP * 3.0
	else:
		$CardRect.position = start_position + Vector2.DOWN * 0.0
