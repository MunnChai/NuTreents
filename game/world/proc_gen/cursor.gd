extends AnimatedSprite2D

@export var highlight_node_2d: Node2D

var pos_offset = Vector2(0, -16)

const RATE_OF_LERP = 20.0

func _ready() -> void:
	disable()

func _process(delta: float) -> void:
	global_position = global_position.lerp(highlight_node_2d.global_position + pos_offset, delta * RATE_OF_LERP)

func set_low() -> void:
	play()
	pos_offset = Vector2(0, 10)

func set_medium() -> void:
	stop()
	pos_offset = Vector2(0, 0)

func set_high() -> void:
	stop()
	pos_offset = Vector2(0, -16)

var is_enabled := true

func enable() -> void:
	if is_enabled:
		return
	is_enabled = true
	show()
	global_position = highlight_node_2d.global_position + pos_offset

func disable() -> void:
	if !is_enabled:
		return
	is_enabled = false
	hide()
	global_position = highlight_node_2d.global_position + pos_offset
