class_name HoverInfoBox
extends Control

## HOVER (INFO) BOX
## The box with an arrow that shows up when you hover
## on cards in the tree menu

## ---

## REFERENCES
@onready var label: RichTextLabel = %RichTextLabel

static var instance: HoverInfoBox # Psuedo-singleton access

var is_visible := false

func _ready() -> void:
	instance = self
	jump_to_hidden()

#region SHOW/HIDE CONTENT

func show_content(content: String) -> void:
	switch_to_visible()
	if label.text != content: # Content changed!
		label.text = content
		TweenUtil.pop_delta(self, Vector2(0.1, 0.1), 0.15, Tween.TRANS_CUBIC)
func hide_content() -> void:
	switch_to_hidden()

func switch_to_visible() -> void:
	if is_visible:
		pass
	is_visible = true
	
	show()
	
	## MOVE UP AND FADE IN
	var starting_position = position
	TweenUtil.whoosh(self, starting_position, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
	TweenUtil.fade(self, 1.0, 0.1, Tween.TRANS_CUBIC)
	TweenUtil.pop_delta(self, Vector2(0.1, 0.1), 0.15, Tween.TRANS_CUBIC)
	## BUG: Pops twice upon switching between cards...

func switch_to_hidden() -> void:
	if not is_visible:
		pass
	is_visible = false
	
	## MOVE DOWN AND FADE OUT, dudeee
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.3, Tween.TRANS_EXPO, Tween.EASE_IN)
	TweenUtil.fade(self, 0.0, 0.15, Tween.TRANS_CUBIC).finished.connect(_finish_switch_to_hidden)
func _finish_switch_to_hidden() -> void:
	hide()
func jump_to_hidden() -> void:
	is_visible = false
	modulate.a = 0
	hide()

#endregion

## Moves the arrow pivot of the hover box to the given position
## (In UI space)
func move_to_pivot(global_pivot_position: Vector2) -> void:
	global_position = global_pivot_position
