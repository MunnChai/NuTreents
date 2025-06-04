class_name ShopCard
extends PanelContainer

@export var tree_type: Global.TreeType
@onready var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(tree_type)

@onready var title: RichTextLabel = %Title
@onready var icon: TextureRect = %Icon

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var margin_container = $MarginContainer
@onready var hidden_button = $HiddenButton

var is_hovering := false
var is_pressed := false
var is_selected := false
var is_removed := false

signal pressed

func _ready():
	_init_visuals()

func _init_visuals():
	title.text = tree_stat.name
	icon.texture = icon.texture.duplicate()
	icon.texture.atlas = tree_stat.tree_icon

func _input(event: InputEvent):
	return

func select():
	is_selected = true
	TweenUtil.scale_to(self, Vector2(0.9, 0.9), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	TweenUtil.fade(self, 0.5, 0.1)

func deselect():
	is_selected = false
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	TweenUtil.fade(self, 1, 0.3)

func remove():
	is_removed = true
	
	# Munn: This is all jank so the other cards can move smoothly when this is deleted
	margin_container.queue_free()
	nine_patch_rect.queue_free()
	
	var tween = TweenUtil.get_new_tween(self, "custom_minimum_size")
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "custom_minimum_size", Vector2(0, custom_minimum_size.y), 0.4)
	
	await get_tree().create_timer(0.25).timeout
	
	queue_free()

func _on_mouse_pressed():
	if is_removed:
		return
	
	if not is_hovering:
		return
	
	SfxManager.play_sound_effect("ui_click")
	TweenUtil.scale_to(self, Vector2(0.9, 0.9), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_released():
	if is_removed:
		return
	
	if not is_hovering:
		return
	
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	pressed.emit()

func _on_mouse_entered():
	if is_removed:
		return
	
	is_hovering = true
	
	if is_selected:
		return
	
	SfxManager.play_sound_effect("ui_click")
	TweenUtil.scale_to(self, Vector2(1.1, 1.1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_exited():
	if is_removed:
		return
	
	is_hovering = false
	
	if is_selected:
		return
	
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
