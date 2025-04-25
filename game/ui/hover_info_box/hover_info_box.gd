class_name HoverInfoBox
extends Control

@onready var label: RichTextLabel = %RichTextLabel

static var instance: HoverInfoBox

## TODO: Fade in/out...

func _ready() -> void:
	instance = self
	hide()

func set_content(content: String) -> void:
	label.text = content

func pop() -> void:
	TweenUtil.pop_delta(self, Vector2(0.1, 0.1), 0.15, Tween.TRANS_CUBIC)
	#scale = Vector2(1.1, 1.1)
	#create_tween().tween_property(self, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
