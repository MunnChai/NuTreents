@tool
class_name JuicyButton
extends Control

@export var button: Button ## The actual real button that handles the state logic

func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.pressed.connect(_on_pressed)
	
	button.focus_entered.connect(_on_focus)
	button.focus_exited.connect(_on_unfocus)

func _process(delta: float) -> void:
	if not button:
		return
	
	if %ButtonText.text != button.text:
		%ButtonText.text = button.text
	
	if not is_down:
		if button.is_hovered() or is_focused:
			if not is_highlighted:
				is_highlighted = true
			%AnimationPlayer.play("button_hover")
		else:
			if is_highlighted:
				is_highlighted = false
			%AnimationPlayer.play("button_up")

var is_highlighted := false

var is_down := false
var is_focused := false

func _on_button_down() -> void:
	## Set to down sprite
	%AnimationPlayer.play("button_down")
	TweenUtil.pop_delta(%ButtonScalePivot, Vector2(0.1, 0.1), 0.3)
	SfxManager.play_sound_effect("ui_click")
	is_down = true

func _on_button_up() -> void:
	## Set to up sprite
	%AnimationPlayer.play("button_up")
	TweenUtil.pop_delta(%ButtonScalePivot, Vector2(0.1, 0.1), 0.3)
	is_down = false
	
	button.release_focus()

func _on_pressed() -> void:
	print("Pressed!")
	SfxManager.play_sound_effect("ui_click")

func _on_focus() -> void:
	is_focused = true

func _on_unfocus() -> void:
	is_focused = false
