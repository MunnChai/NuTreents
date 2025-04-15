class_name TreeCard
extends Control

@export var tree_image: Texture2D
@export var tree_type: Global.TreeType

@export var special_card_image: Texture2D

@onready var start_position: Vector2 = $CardRect.position

@onready var offset: Vector2 = Vector2.ZERO

var is_highlighted = false
var is_selected = false

func _ready() -> void:
	$CardRect/TreeIconRect.texture = tree_image
	
	TreeManager.tree_placed.connect(_on_tree_placed)
	
	if special_card_image != null:
		$CardRect.texture = special_card_image

func _on_tree_placed(new_twee: Twee) -> void:
	if is_selected:
		pop()

func _on_mouse_entered() -> void:
	#$CardRect.global_position = start_position + Vector2.UP * 5.0
	#$CardRect.modulate = Color.RED
	is_highlighted = true
	if not is_selected:
		SfxManager.play_sound_effect("ui_click")
		pop()

func _on_mouse_exited() -> void:
	#$CardRect.global_position = start_position
	#$CardRect.modulate = Color.WHITE
	is_highlighted = false

const OFFSET_DECAY_CONSTANT := 32.0

var time := 0.0

var is_available := false

func _process(delta: float) -> void:
	time += delta
	
	if is_highlighted and not is_selected and Input.is_action_just_pressed("lmb"):
		TreeMenu.instance.set_currently_selected_tree_type(tree_type)
		SfxManager.play_sound_effect("ui_click")
	
	is_selected = TreeMenu.instance.get_currently_selected_tree_type() == tree_type
	
	if is_highlighted or is_selected:
		#$CardRect.position = start_position + Vector2.UP * 3.0
		if is_selected:
			offset = MathUtil.decay(offset, Vector2.UP * 10.0, OFFSET_DECAY_CONSTANT, delta)
		elif is_highlighted:
			offset = MathUtil.decay(offset, Vector2.UP * 3.0, OFFSET_DECAY_CONSTANT, delta)
	else:
		offset = MathUtil.decay(offset, Vector2.ZERO, OFFSET_DECAY_CONSTANT, delta)
		#$CardRect.position = start_position + Vector2.DOWN * 0.0
	
	$CardRect.position = start_position + offset
	
	var percent_of_full := float(TreeManager.nutreents) / float(TreeRegistry.get_new_twee(tree_type).tree_stat.cost_to_purchase)
	percent_of_full = clampf(percent_of_full, 0.0, 1.0)
	
	if percent_of_full >= 1.0:
		if not is_available:
			is_available = true
			pop()
			SfxManager.play_sound_effect("ui_click")
	else:
		is_available = false
	
	%WaitRect.scale.y = MathUtil.decay(%WaitRect.scale.y, 1.0 - percent_of_full, 20.0, delta)
	
	#if not TreeManager.enough_n(TreeRegistry.get_new_twee(tree_type).tree_stat.cost_to_purchase):
		#$CardRect.modulate = Color.DARK_GRAY
	#else:
		#$CardRect.modulate = Color.WHITE
	
	if is_selected and is_available:
		$CardRect.position += sin(time * 5.0) * Vector2.UP * 2.0
	else:
		time = 0.0

func pop() -> void:
	$CardRect.scale = Vector2(1.2, 1.2)
	create_tween().tween_property($CardRect, "scale", Vector2.ONE, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
