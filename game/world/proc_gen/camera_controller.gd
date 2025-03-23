extends Camera2D

# Camera move constants
const MOUSE_DRAG_STRENGTH: float = 70

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
	## START THE CAMERA ON THE CENTRE WITH VERY SCUFFED MATH CALCULATION
	## (This assumes the map is square)
	global_position = Global.MAP_SIZE.y / 2.0 * Vector2.DOWN * 16.0 + Vector2.RIGHT * 16.0

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("move_cam"):
		move_cam(delta)
	
	if Input.is_action_just_released("zoom_cam_in"):
		zoom_cam_in(delta)
	
	if Input.is_action_just_released("zoom_cam_out"):
		zoom_cam_out(delta)
	
	prev_mouse_pos = get_viewport().get_mouse_position()
	
	lock_camera()


const X_MAX: float = 32 * Global.MAP_SIZE.x / 2
const Y_MAX: float = 16 * Global.MAP_SIZE.y / 2
func lock_camera():
	global_position.x = clamp(global_position.x, -X_MAX, X_MAX)
	global_position.y = clamp(global_position.y, 0, Y_MAX * 2)

func move_cam(delta: float) -> void:
	print("YAR")
	var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var distance_moved: Vector2 = curr_mouse_pos - prev_mouse_pos
	position -= distance_moved * MOUSE_DRAG_STRENGTH * delta * (1.0 / FIXED_ZOOM_SIZES[current_zoom_index])

func zoom_cam_in(delta: float) -> void:
	current_zoom_index += 1
	
	if (current_zoom_index >= FIXED_ZOOM_SIZES.size()):
		current_zoom_index = FIXED_ZOOM_SIZES.size() - 1
	
	zoom = Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index]

func zoom_cam_out(delta: float) -> void:
	current_zoom_index -= 1
	
	if (current_zoom_index < 0):
		current_zoom_index = 0
	
	zoom = Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index]
