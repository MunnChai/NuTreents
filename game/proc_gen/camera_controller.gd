extends Camera2D

const MOUSE_DRAG_STRENGTH: float = 100

var prev_mouse_pos: Vector2

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("move_cam"):
		move_cam(delta)
	
	prev_mouse_pos = get_global_mouse_position()

func move_cam(delta: float) -> void:
	var curr_mouse_pos: Vector2 = get_global_mouse_position()
	
	var distance_moved: Vector2 = curr_mouse_pos - prev_mouse_pos
	
	position -= distance_moved * MOUSE_DRAG_STRENGTH * delta
