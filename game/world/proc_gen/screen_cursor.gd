class_name ScreenCursor
extends Sprite2D

static var instance: ScreenCursor

var offset_position := Vector2.ZERO

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	global_position = get_viewport().get_camera_2d().global_position + offset_position
	
	var camera_bounds = get_viewport().get_visible_rect().size
	
	offset_position = offset_position.clamp(-camera_bounds / 8.0, camera_bounds / 8.0)
