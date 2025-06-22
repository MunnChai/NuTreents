class_name GridMovementComponent
extends Node2D

## The node whose position this component will adjust. If left null, it will be set to the parent of this component.
@export var actor: Node2D

@export_category("Movement Parameters")
@export var movement_duration: float = 0.0
@export var ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans: Tween.TransitionType = Tween.TRANS_CUBIC
@export var bounce_amount: float

var grid_position_component: GridPositionComponent
var sprite_2d: Sprite2D

signal move_in_direction(direction: Vector2i)

func _ready() -> void:
	if not actor:
		actor = get_parent()
	
	grid_position_component = Components.get_component(actor, GridPositionComponent)
	sprite_2d = Components.get_component(actor, Sprite2D, "", true)

func move_to_position(target_position: Vector2i) -> void:
	var current_position = grid_position_component.get_pos()
	var direction = target_position - current_position
	move_in_direction.emit(direction)
	
	var global_pos = MapUtility.map_to_global(current_position)
	var target_global_pos = MapUtility.map_to_global(target_position)
	
	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.set_ease(ease)
	pos_tween.set_trans(trans)
	pos_tween.tween_property(actor, "global_position", target_global_pos, movement_duration)
	
	var sprite_2d: Sprite2D = Components.get_component(actor, Sprite2D)
	
	var bounce_tween: Tween = get_tree().create_tween()
	bounce_tween.set_trans(trans)
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(sprite_2d, "position:y", -bounce_amount, movement_duration / 2).as_relative()
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(sprite_2d, "position:y", bounce_amount, movement_duration / 2).as_relative()
	
	grid_position_component.move(direction)

func move_to_and_back(target_position: Vector2i) -> void:
	var current_position = grid_position_component.get_pos()
	var direction = target_position - current_position
	move_in_direction.emit(direction)
	
	var global_pos = MapUtility.map_to_global(current_position)
	var target_global_pos = MapUtility.map_to_global(target_position)
	
	var pos_tween: Tween = get_tree().create_tween()
	pos_tween.set_ease(ease)
	pos_tween.set_trans(trans)
	pos_tween.tween_property(actor, "global_position", target_global_pos, movement_duration / 2)
	pos_tween.tween_property(actor, "global_position", global_pos, movement_duration / 2)
	
	if not sprite_2d:
		return
	
	var bounce_tween: Tween = get_tree().create_tween()
	bounce_tween.set_trans(trans)
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(sprite_2d, "position:y", -bounce_amount, movement_duration / 4).as_relative()
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(sprite_2d, "position:y", bounce_amount, movement_duration / 4).as_relative()
	bounce_tween.set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(sprite_2d, "position:y", -bounce_amount, movement_duration / 4).as_relative()
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(sprite_2d, "position:y", bounce_amount, movement_duration / 4).as_relative()
