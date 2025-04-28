class_name FloatingTooltip
extends PanelContainer

## FLOATING TOOLTIP
## The "floating box" tooltip attached to the mouse cursor

## ---

## REFERENCES
@onready var label: RichTextLabel = %TooltipText

## STATE
var is_visible := false
var force_hidden := false

@onready var start_position: Vector2 = position

static var instance: FloatingTooltip # Psuedo-singleton access

func _ready() -> void:
	instance = self
	jump_to_hidden()

func _process(delta: float) -> void:
	if force_hidden:
		switch_to_hidden()

func show_content(content: String) -> void:
	if force_hidden:
		return
	
	switch_to_visible()
	if label.text != content:
		label.text = content
		TweenUtil.pop_delta(self, Vector2(0.12, 0.12), 0.25)

func hide_content() -> void:
	switch_to_hidden()

func switch_to_visible() -> void:
	if force_hidden:
		return
	
	if is_visible:
		return
	is_visible = true
	
	show()
	TweenUtil.fade(self, 1.0, 0.1)

func switch_to_hidden() -> void:
	if not is_visible:
		return
	is_visible = false
	
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(func(): hide())
func jump_to_hidden() -> void:
	is_visible = false
	hide()
	modulate.a = 0
