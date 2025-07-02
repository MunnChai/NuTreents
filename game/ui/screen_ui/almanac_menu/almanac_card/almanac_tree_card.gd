class_name AlmanacTreeCard
extends PanelContainer

var type: Global.TreeType
var tree_stat: TreeStatResource

@onready var title: RichTextLabel = %Title
@onready var icon: TextureRect = %Icon

var is_hovering := false
var is_pressed := false
var is_selected := false
var is_removed := false

signal pressed

func _ready():
	init_tree_card()

func init_tree_card():
	tree_stat = TreeRegistry.get_twee_stat(type)
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
