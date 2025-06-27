class_name StatusEffect
extends Resource

@export var duration: float

@export_category("Visuals")
@export var color_modulate: Color = Color(1, 1, 1, 1)
@export var effect_icon: Texture2D
@export var particles: PackedScene

## This function should get the Components that it wants to alter, and alter them by a set amount
func apply_status_effect(entity: Node2D) -> void:
	var sprite_2d: Sprite2D = Components.get_component(entity, Sprite2D)
	if sprite_2d != null:
		sprite_2d.self_modulate = blend(sprite_2d.self_modulate, color_modulate)

## This function should get the Components that it was altering, and revert the alterations that it made
func remove_status_effect(entity: Node2D) -> void:
	var sprite_2d: Sprite2D = Components.get_component(entity, Sprite2D)
	if sprite_2d != null:
		sprite_2d.self_modulate = undo_blend(sprite_2d.self_modulate, color_modulate)



# TODO: Probably change these to a better blending function
func blend(color: Color, color_to_blend: Color) -> Color:
	var new_color: Color = color * color_to_blend
	return new_color

const MIN_DIVISIBLE: float = 0.05
func undo_blend(color: Color, color_to_remove: Color) -> Color:
	var min_color: Color = Color(MIN_DIVISIBLE, MIN_DIVISIBLE, MIN_DIVISIBLE, MIN_DIVISIBLE)
	var max_color: Color = Color(1, 1, 1, 1)
	color_to_remove = color_to_remove.clamp(min_color, max_color)
	color = color.clamp(min_color, max_color)
	var new_color: Color = color / color_to_remove
	return new_color
