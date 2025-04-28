class_name GameCursor
extends Control

## GAME CURSOR
## In-game replacement for the typical OS cursor
## Handles positioning, style type, and the tooltip

## ---

@export var pointer_texture: Texture2D
@export var hand_texture: Texture2D

static var instance: GameCursor

func _ready() -> void:
	instance = self
	
	hide_tooltip()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

var force_hide_tooltip := false
var is_tooltip_visible := true
@onready var tooltip_start_position: Vector2 = $PanelContainer.position

var current_priority := 0

func hide_tooltip() -> void:
	if not is_tooltip_visible:
		return
	is_tooltip_visible = false
	
	current_priority = -1
	
	TweenUtil.fade($PanelContainer, 0.0, 0.1).finished.connect(func(): $PanelContainer.hide())

func show_tooltip(content: String, priority: int) -> void:
	if force_hide_tooltip or HoverInfoBox.instance.visible:
		return
	if %TooltipText.text != content:
		#$PanelContainer.position += Vector2.DOWN * 10.0
		#TweenUtil.whoosh($PanelContainer, tooltip_start_position, 0.5)
		TweenUtil.pop_delta($PanelContainer, Vector2(0.12, 0.12), 0.25)
		%TooltipText.text = content
	
	if is_tooltip_visible:
		return
	
	if priority < current_priority:
		return
	
	is_tooltip_visible = true
	
	current_priority = priority
	
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
	if force_hide_tooltip:
		hide_tooltip()

func _notification(notif):
	match notif:
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
