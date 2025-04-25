class_name GameCursor
extends Control

@export var pointer_texture: Texture2D
@export var hand_texture: Texture2D

static var instance: GameCursor

func _ready() -> void:
	instance = self
	hide_tooltip()

var force_hide_tooltip := false
var is_tooltip_visible := true
@onready var tooltip_start_position: Vector2 = $PanelContainer.position

func hide_tooltip() -> void:
	if not is_tooltip_visible:
		return
	is_tooltip_visible = false
	TweenUtil.fade($PanelContainer, 0.0, 0.1).finished.connect(func(): $PanelContainer.hide())
func show_tooltip(content: String) -> void:
	if force_hide_tooltip or HoverInfoBox.instance.visible:
		return
	if %TooltipText.text != content:
		#$PanelContainer.position += Vector2.DOWN * 10.0
		#TweenUtil.whoosh($PanelContainer, tooltip_start_position, 0.5)
		TweenUtil.pop_delta($PanelContainer, Vector2(0.12, 0.12), 0.25)
		%TooltipText.text = content
	
	if is_tooltip_visible:
		return
	
	is_tooltip_visible = true
	$PanelContainer.show()
	TweenUtil.fade($PanelContainer, 1.0, 0.1)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	var current_shape = Input.get_current_cursor_shape()
	match current_shape:
		CURSOR_POINTING_HAND:
			$TextureRect.texture = hand_texture
		_:
			$TextureRect.texture = pointer_texture
	#if force_hide_tooltip or HoverInfoBox.instance.visible:
		#hide_tooltip()

func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			#print('Mouse left window')
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			#print('Mouse entered window')
