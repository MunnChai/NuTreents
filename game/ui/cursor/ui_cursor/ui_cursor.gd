class_name UICursor
extends Control

## UI CURSOR
## The in-game replacement for the typical OS cursor
## This cursor exists on the UI control layer
## Handles positioning, current texture, and tooltip display

## TODO
## - Implement clamp to camera bounds
## - Gamepad support

@export_category("Cursor Texture")
const DEFAULT_CURSOR_SHAPE := CursorShape.CURSOR_ARROW
## Shape to texture map... for animations, use an AnimatedTexture
@export var cursor_shape_textures: Dictionary[CursorShape, Texture2D]
var cursor_shape_override: CursorShape = -1 ## Force override the CursorShape... if isn't -1
var force_wait := false ## Force the WAITING... shape

@onready var cursor_icon: TextureRect = %CursorIcon
@onready var floating_tooltip: FloatingTooltip = %FloatingTooltip

@onready var previous_mouse_position := get_global_mouse_position()
var mouse_velocity := Vector2.ZERO

var clamp_to_camera_bounds := true ## Clamp to camera bounds

static var instance: UICursor

func _ready() -> void:
	instance = self
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	_update_cursor_position()
	_update_mouse_velocity(delta)
	_update_cursor_shape()

func _update_cursor_position() -> void:
	global_position = get_global_mouse_position()

func _update_mouse_velocity(delta: float) -> void:
	var new_mouse_velocity = global_position - previous_mouse_position
	if new_mouse_velocity > mouse_velocity:
		mouse_velocity = new_mouse_velocity
	else:
		mouse_velocity = MathUtil.decay(mouse_velocity, new_mouse_velocity, 18.0, delta)
	previous_mouse_position = global_position

## Update the cursor shape based on Input's current cursor shape
## Use CURSOR_WAIT if force_wait is true
## Use override if override is not null
func _update_cursor_shape() -> void:
	var current_shape = Input.get_current_cursor_shape()
	
	if force_wait:
		current_shape = Input.CURSOR_WAIT
	elif cursor_shape_override != -1:
		current_shape = cursor_shape_override
	
	set_texture_from_cursor_shape(current_shape)

## Retrieves the corresponding texture from the shape-texture map
## and sets the texture of the cursor
## Defaults to DEFAULT_CURSOR_SHAPE if it is not found in the map
func set_texture_from_cursor_shape(shape: CursorShape) -> void:
	var default_texture = cursor_shape_textures.get(DEFAULT_CURSOR_SHAPE)
	var cursor_shape_texture = cursor_shape_textures.get(shape, default_texture)
	cursor_icon.texture = cursor_shape_texture

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_cursor_shape()

## Notification signal to detect entering/exiting the window
## and enable/disable accordingly, so the OS cursor is visible when outside
func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
