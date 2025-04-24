class_name GameCursor
extends Control

@export var pointer_texture: Texture2D
@export var hand_texture: Texture2D

static var instance: GameCursor

func _ready() -> void:
	instance = self

func hide_tooltip() -> void:
	$PanelContainer.hide()
func show_tooltip(content: String) -> void:
	$PanelContainer.show()
	if %TooltipText.text != content:
		TweenUtil.pop_delta($PanelContainer, Vector2(0.25, 0.25), 0.35)
	%TooltipText.text = content

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	var current_shape = Input.get_current_cursor_shape()
	match current_shape:
		CURSOR_POINTING_HAND:
			$TextureRect.texture = hand_texture
		_:
			$TextureRect.texture = pointer_texture

func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#print('Mouse left window')
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			#print('Mouse entered window')
