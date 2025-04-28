class_name GameCursor
extends Control

## GAME CURSOR
## In-game replacement for the typical OS cursor
## Handles positioning, style type, and the tooltip

## ---

## TODO: Add support for animated textures..? Or can you just use animated texture 2d...
@export var cursor_shape_textures: Dictionary[CursorShape, Texture2D]

## REFERENCES
@onready var cursor_icon: TextureRect = %CursorIcon
@onready var floating_tooltip: FloatingTooltip = %FloatingTooltip

@onready var previous_mouse_position := get_global_mouse_position()
var mouse_velocity := Vector2.ZERO

static var instance: GameCursor

func _ready() -> void:
	instance = self
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	var new_mouse_velocity = global_position - previous_mouse_position
	if new_mouse_velocity > mouse_velocity:
		mouse_velocity = new_mouse_velocity
	else:
		mouse_velocity = MathUtil.decay(mouse_velocity, new_mouse_velocity, 18.0, delta)
	previous_mouse_position = global_position
	
	_update_cursor_shape()

## Update the cursor shape based on Input's current cursor shape
func _update_cursor_shape() -> void:
	var current_shape = Input.get_current_cursor_shape()
	var default_texture = cursor_shape_textures.get(CursorShape.CURSOR_ARROW)
	var cursor_shape_texture = cursor_shape_textures.get(current_shape, default_texture)
	cursor_icon.texture = cursor_shape_texture

## Notification signal to detect entering/exiting the window
## and enable/disable accordingly
func _notification(notif):
	match notif:
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
