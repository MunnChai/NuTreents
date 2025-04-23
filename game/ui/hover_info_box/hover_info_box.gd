class_name HoverInfoBox
extends Control

@onready var label: RichTextLabel = %RichTextLabel

static var instance: HoverInfoBox

func _ready() -> void:
	instance = self
	hide()

func set_content(content: String) -> void:
	label.text = content

func pop() -> void:
	scale = Vector2(1.1, 1.1)
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
