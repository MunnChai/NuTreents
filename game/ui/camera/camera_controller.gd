class_name Camera
extends Camera2D

# Camera move constants
const MOUSE_DRAG_STRENGTH: float = 70

# Camera zoom constants
const FIXED_ZOOM_SIZES: Array[float] = [
	1,
	2,
	4,
	6,
	8,
]

# Camera move vars
var prev_mouse_pos: Vector2

# Camera zoom vars
var current_zoom_index: int = 2

var core_position: Vector2

static var instance: Camera

func get_percent_zoom() -> float:
	return (current_zoom_index / float(FIXED_ZOOM_SIZES.size() - 1))

func _ready() -> void:
	instance = self
	zoom = Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index]
	## START THE CAMERA ON THE CENTRE WITH VERY SCUFFED MATH CALCULATION
	## (This assumes the map is square)
	core_position = Global.ORIGIN + Vector2i(16, 0)
	global_position = core_position

const ZOOM_DECAY := 20.0
const SMOOTH_MOVE_RATE = 50.0

const MAX_SPEED = 500.0
const ACCELERATION = 10.0
const DECELERATION_RATE = 10.0

var velocity := Vector2.ZERO

var move_position_by := Vector2.ZERO

func _process(delta: float) -> void:
	move_position_by = Vector2.ZERO
	
	if Input.is_action_just_released("zoom_cam_in"):
		zoom_cam_in(TimeUtil.unscaled_delta(delta))
	
	if Input.is_action_just_released("zoom_cam_out"):
		zoom_cam_out(TimeUtil.unscaled_delta(delta))
	
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if (direction.length_squared() > 0.01):
		velocity = MathUtil.decay(velocity, direction * MAX_SPEED, ACCELERATION, TimeUtil.unscaled_delta(delta))
	else:
		velocity = MathUtil.decay(velocity, Vector2.ZERO, DECELERATION_RATE, TimeUtil.unscaled_delta(delta))
	#move_position_by += velocity * (1.0 / FIXED_ZOOM_SIZES[current_zoom_index]) * TimeUtil.unscaled_delta(delta)

	if Input.is_action_pressed("move_cam"):
		move_cam(TimeUtil.unscaled_delta(delta))
	
	prev_mouse_pos = get_viewport().get_mouse_position()
	
	var prev_zoom = zoom
	var before_pos = get_global_mouse_position()
	
	zoom = MathUtil.decay(zoom, Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index] / get_tree().root.content_scale_factor, ZOOM_DECAY, TimeUtil.unscaled_delta(delta))
	zoom = Vector2(max(zoom.x, 0.1), max(zoom.y, 0.1))
	
	## BUG: Moves extra fast during zooming because not accounting for extra motion..?
	## https://forum.godotengine.org/t/how-to-zoom-camera-to-mouse/37348
	if zoom != prev_zoom:
		core_position += before_pos - (get_global_mouse_position() - move_position_by)
	
	core_position += velocity * (1.0 / FIXED_ZOOM_SIZES[current_zoom_index]) * TimeUtil.unscaled_delta(delta)
	
	lock_camera()
	
	if CameraShake.instance != null:
		global_position = core_position + CameraShake.instance.final_offset
		rotation = CameraShake.instance.final_rotation
	else:
		global_position = core_position

const TILE_SIZE := Vector2i(32, 16) 
func lock_camera():
	var world_size = Global.current_world_size
	if not world_size in Global.WorldSize.values():
		world_size = Global.WorldSize.SMALL
	var map_size: Vector2i = WorldSettings.world_size_settings[Global.current_world_size].map_size
	var x_max = TILE_SIZE.x * map_size.x / 2
	var y_max = TILE_SIZE.y * map_size.y / 2
	core_position.x = clamp(core_position.x, Global.ORIGIN.x - x_max, Global.ORIGIN.x + x_max)
	core_position.y = clamp(core_position.y, Global.ORIGIN.y - y_max, Global.ORIGIN.y + y_max)

func move_cam(delta: float) -> void:
	var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var distance_moved: Vector2 = curr_mouse_pos - prev_mouse_pos
	core_position -= distance_moved * MOUSE_DRAG_STRENGTH * delta * (1.0 / FIXED_ZOOM_SIZES[current_zoom_index])
	move_position_by -= distance_moved * MOUSE_DRAG_STRENGTH * delta * (1.0 / FIXED_ZOOM_SIZES[current_zoom_index])

func zoom_cam_in(delta: float) -> void:
	current_zoom_index += 1
	
	if (current_zoom_index >= FIXED_ZOOM_SIZES.size()):
		current_zoom_index = FIXED_ZOOM_SIZES.size() - 1
	
	#zoom = Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index]

func zoom_cam_out(delta: float) -> void:
	current_zoom_index -= 1
	
	if (current_zoom_index < 0):
		current_zoom_index = 0
	
	#zoom = Vector2(1, 1) * FIXED_ZOOM_SIZES[current_zoom_index]
