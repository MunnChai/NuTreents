class_name CursorWoodenArrow
extends AnimatedSprite2D

const RATE_OF_DECAY = 22.0

@onready var cursor_position := global_position
@onready var current_global_position := global_position
var pos_offset = Vector2(0, -16)
var is_enabled := true

func _ready() -> void:
	disable()

func _process(delta: float) -> void:
	current_global_position = MathUtil.decay(current_global_position, cursor_position + pos_offset, RATE_OF_DECAY, delta)
	global_position = current_global_position

func set_cursor_position(new_position: Vector2) -> void:
	cursor_position = new_position

func set_height(value: String) -> void:
	match value: # Remember: bigger value is down!
		"low": 
			pos_offset = Vector2(0, 10)
		"medium":
			pos_offset = Vector2(0, 0)
		"high":
			pos_offset = Vector2(0, -16)

func enable() -> void:
	if is_enabled:
		return
	is_enabled = true
	visible = true
	current_global_position = cursor_position + pos_offset

func disable() -> void:
	if !is_enabled:
		return
	is_enabled = false
	visible = false
