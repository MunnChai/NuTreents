extends Camera2D

# Camera move constants
const MOUSE_DRAG_STRENGTH: float = 50

const ZOOM_SMOOTH_SPEED: float = 75.0

# Camera zoom constants
const FIXED_ZOOM_SIZES: Array[float] = [
	1,
	2,
	4,
	6,
	8
]

# Camera move vars
var prev_mouse_pos: Vector2

# Camera zoom vars
var current_zoom_index: int = 2


func _ready() -> void:
	zoom = Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index]

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("move_cam"):
		move_cam(delta)
	
	if Input.is_action_just_released("zoom_cam_in"):
		zoom_cam_in(delta)
	
	if Input.is_action_just_released("zoom_cam_out"):
		zoom_cam_out(delta)
	
	prev_mouse_pos = get_global_mouse_position()

func move_cam(delta: float) -> void:
	var curr_mouse_pos: Vector2 = get_global_mouse_position()
	
	var distance_moved: Vector2 = curr_mouse_pos - prev_mouse_pos
	
	position -= distance_moved * MOUSE_DRAG_STRENGTH * delta

func zoom_cam_in(delta: float) -> void:
	current_zoom_index += 1
	
	if (current_zoom_index >= FIXED_ZOOM_SIZES.size()):
		current_zoom_index = FIXED_ZOOM_SIZES.size() - 1
	
	
	zoom = zoom.lerp(Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index], delta * ZOOM_SMOOTH_SPEED)

func zoom_cam_out(delta: float) -> void:
	current_zoom_index -= 1
	
	if (current_zoom_index < 0):
		current_zoom_index = 0
	
	zoom = zoom.lerp(Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index], delta * ZOOM_SMOOTH_SPEED)
