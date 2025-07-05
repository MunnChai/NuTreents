@tool
class_name ResearchNode
extends Control

enum ResearchState {
	LOCKED = 0, 
	UNLOCKABLE = LOCKED + 1,
	UNLOCKED = UNLOCKABLE + 1,
}

#region Exports

@export var state: ResearchState = ResearchState.LOCKED:
	set(new_state):
		state = new_state
		match new_state:
			ResearchState.LOCKED:
				modulate = Color("#646464")
				get_node("%Background").texture = locked_icon
			ResearchState.UNLOCKABLE:
				modulate = Color.WHITE
				get_node("%Background").texture = unlockable_icon
			ResearchState.UNLOCKED:
				modulate = Color.WHITE
				get_node("%Background").texture = unlocked_icon

@export var research_resource: ResearchNodeResource:
	set(new_resource):
		if new_resource != null:
			get_node("%Icon").texture = new_resource.icon
		else:
			get_node("%Icon").texture = null
		research_resource = new_resource

@export var required_nodes: Array[ResearchNode]

@export_group("BackgroundTextures")
@export var locked_icon: Texture2D
@export var unlockable_icon: Texture2D
@export var unlocked_icon: Texture2D

#endregion

@onready var background: NinePatchRect = %Background
@onready var icon: TextureRect = %Icon

signal pressed(research_node: ResearchNode)
signal unlocked(research_node: ResearchNode)
signal focused(research_node: ResearchNode)

var is_hovering := false
var is_pressed := false
var is_selected := false

func unlock_research_node() -> void:
	state = ResearchState.UNLOCKED
	unlocked.emit(research_resource)

func select():
	is_selected = true
	TweenUtil.scale_to(self, Vector2(0.9, 0.9), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	TweenUtil.fade(self, 0.5, 0.1)

func deselect():
	is_selected = false
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)
	TweenUtil.fade(self, 1, 0.3)

func _on_mouse_pressed():
	if not is_hovering:
		return
	
	pressed.emit(self)
	SfxManager.play_sound_effect("ui_click")
	TweenUtil.scale_to(self, Vector2(0.9, 0.9), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_released():
	if not is_hovering:
		return
	
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_entered():
	is_hovering = true
	
	if is_selected:
		return
	
	TweenUtil.scale_to(self, Vector2(1.1, 1.1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_mouse_exited():
	is_hovering = false
	
	if is_selected:
		return
	
	TweenUtil.scale_to(self, Vector2(1, 1), 0.3, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_OUT)

func _on_focus_entered():
	focused.emit(self)
