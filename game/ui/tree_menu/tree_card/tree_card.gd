class_name TreeCard
extends Control

## TREE CARD
## The HUD bar UI element for a tree

## ---

## The type of tree that this card represents
@export var tree_type: Global.TreeType
@onready var stat: TreeStatResource = TreeRegistry.get_twee_stat(tree_type)

## REFERENCES
@onready var card_image: TextureRect = %CardImage
@onready var tree_image: TextureRect = %TreeImage
@onready var wait_rect: ColorRect = %WaitRect
@onready var tooltip_pivot: Control = %TooltipPivot

## STATE
## Is this card highlighted by the mouse cursor? (Not necessarily selected)
var is_highlighted := false
## Is this card actively selected? (Chosen to be placed)
var is_selected := false
## Is this card available based on the player's stats and nutreents count?
var is_available := false
var elapsed_time := 0.0 ## TODO: Optimize this or something..? Make it a looping animation instead?

func _ready() -> void:
	_init_visuals()
	TreeManager.tree_placed.connect(_on_tree_placed)

func _init_visuals() -> void:
	tree_image.texture = stat.tree_icon
	if stat.special_card_background_override != null:
		card_image.texture = stat.special_card_background_override

func _process(delta: float) -> void:
	elapsed_time += delta
	
	_detect_and_handle_selection()
	is_selected = TreeMenu.instance.get_currently_selected_tree_type() == tree_type
	_update_availability(delta)
	_update_card_image_offset(delta)

func _detect_and_handle_selection() -> void:
	## Not selected, highlighted, and clicked -> Select this tree type
	if is_highlighted and not is_selected and Input.is_action_just_pressed("lmb"):
		TreeMenu.instance.set_currently_selected_tree_type(tree_type)
		SfxManager.play_sound_effect("ui_click")

## Update the offset of the card image rect based on various details
const OFFSET_DECAY_CONSTANT := 32.0 # How fast does offset "lerp"?
const ROTATION_OFFSET_DECAY_CONSTANT := 8.0
var rotation_offset := 0.0
func _update_card_image_offset(delta: float) -> void:
	## Highlighted or selected have different offsets
	if is_highlighted or is_selected:
		if is_selected:
			offset = MathUtil.decay(offset, Vector2.UP * 10.0, OFFSET_DECAY_CONSTANT, delta)
		elif is_highlighted:
			offset = MathUtil.decay(offset, Vector2.UP * 3.0, OFFSET_DECAY_CONSTANT, delta)
	else:
		offset = MathUtil.decay(offset, Vector2.ZERO, OFFSET_DECAY_CONSTANT, delta)
	
	card_image.rotation_degrees = rotation_offset
	
	if not is_highlighted:
		rotation_offset = MathUtil.decay(rotation_offset, 0.0, ROTATION_OFFSET_DECAY_CONSTANT, delta)
	else:
		rotation_offset = MathUtil.decay(rotation_offset, ((get_local_mouse_position() - pivot_offset).x) / 3.0, ROTATION_OFFSET_DECAY_CONSTANT, delta)

	card_image.position = start_position + offset # NOTE that the position is reset every frame.
	
	## SINUSOIDAL MOTION only if SELECTED and PLACEABLE
	if is_selected and is_available:
		card_image.position += sin(elapsed_time * 5.0) * Vector2.UP * 2.0
	else:
		elapsed_time = 0.0

## Update the availability status (Is this card able to be placed at this time?)
func _update_availability(delta: float) -> void:
	var percent_of_full := float(TreeManager.nutreents) / float(TreeRegistry.get_twee_stat(tree_type).cost_to_purchase)
	percent_of_full = clampf(percent_of_full, 0.0, 1.0)
	
	if percent_of_full >= 1.0:
		if not is_available:
			is_available = true
			pop()
			SfxManager.play_sound_effect("ui_click")
	else:
		is_available = false
	
	wait_rect.scale.y = MathUtil.decay(wait_rect.scale.y, 1.0 - percent_of_full, 20.0, delta)

#region EVENT HANDLERS

## A tree has been placed/added by TweeManager!
func _on_tree_placed(new_twee: TweeComposed) -> void:
	if is_selected:
		pop() ## Selected card was just placed!

## Mouse has entered MouseDetector
func _on_mouse_entered() -> void:
	is_highlighted = true
	show_hover_info_box()
	FloatingTooltip.instance.force_hidden = true
	
	#if not is_selected:
	SfxManager.play_sound_effect("ui_click")
	pop()
	
	rotation_offset = clampf(GameCursor.instance.mouse_velocity.x * 2.0, -25, 25) 

## Mouse has exited MouseDetector
func _on_mouse_exited() -> void:
	is_highlighted = false
	hide_hover_info_box()
	FloatingTooltip.instance.force_hidden = false

#endregion

#region HOVER INFO BOX

## Show the hover info box
func show_hover_info_box() -> void:
	HoverInfoBox.instance.move_to_pivot(tooltip_pivot.global_position + Vector2.UP * 5.0)
	HoverInfoBox.instance.show_content(generate_hover_info_box_text_entry())
func hide_hover_info_box() -> void:
	HoverInfoBox.instance.hide_content()

## Generates the hover info box text based on this TreeType and returns the string
func generate_hover_info_box_text_entry() -> String:
	var content: String = ""
	
	if stat == null:
		return "ERROR: Not a valid tree type/no stat resource in the registry!"
	
	content += stat.name.to_upper() + "\n"
	content += "\n"
	content += "[color=d9863e]Costs " + str(stat.cost_to_purchase) + " nutreents\n"
	content += "Has " + str(stat.hp_2) + " HP\n"
	content += stat.description
	#content += "\n"
	#content += "When grown: \n"
	#content += "WATER: " + str(stat.gain_2.y) + "/s" + "\n"
	
	return content

#endregion

#region ANIMATION 

@onready var start_position: Vector2 = card_image.position
@onready var offset: Vector2 = Vector2.ZERO

## Make the card suddenly become bigger, then go back to normal
func pop() -> void:
	TweenUtil.pop_delta(card_image, Vector2(0.2, 0.2), 0.25, Tween.TRANS_CUBIC)

#endregion
