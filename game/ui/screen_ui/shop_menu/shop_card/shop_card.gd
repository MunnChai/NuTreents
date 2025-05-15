class_name ShopCard
extends PanelContainer

@export var tree_type: Global.TreeType
@onready var tree_stat: TreeStatResource = TreeRegistry.get_twee_stat(tree_type)

@onready var title: RichTextLabel = %Title
@onready var icon: TextureRect = %Icon


var is_hovering := false
var is_pressed := false
var is_selected := false


signal pressed

func _ready():
	_init_visuals()

func _init_visuals():
	title.text = tree_stat.name
	icon.texture = icon.texture.duplicate()
	icon.texture.atlas = tree_stat.tree_icon

func _input(event: InputEvent):
	return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and is_hovering:
		if event.is_action_pressed("lmb"):
			_on_mouse_pressed()
		
		if event.is_action_released("lmb"):
			_on_mouse_released()

func select():
	is_selected = true
	TweenUtil.scale_to(self, Vector2(0.9, 0.9), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	TweenUtil.fade(self, 0.5, 0.1)

func deselect():
	is_selected = false
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	TweenUtil.fade(self, 1, 0.3)

func _on_mouse_pressed():
	SfxManager.play_sound_effect("ui_click")
	TweenUtil.scale_to(self, Vector2(0.9, 0.9), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_released():
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	pressed.emit()

func _on_mouse_entered():
	is_hovering = true
	
	if is_selected:
		return
	
	SfxManager.play_sound_effect("ui_click")
	TweenUtil.scale_to(self, Vector2(1.1, 1.1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_exited():
	is_hovering = false
	if is_selected:
		return
	
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
