class_name GridMovementComponent
extends Node2D

## The node whose position this component will adjust. If left null, it will be set to the parent of this component.
@export var actor: Node2D

@export_category("Movement Parameters")
@export var movement_duration: float = 0.0
@export var ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans: Tween.TransitionType = Tween.TRANS_CUBIC
@export var bounce_amount: float

var current_position: Vector2i

signal move_in_direction(direction: Vector2i)

func _ready() -> void:
	if not actor:
		actor = get_parent()

func set_current_position(pos: Vector2i) -> void:
	current_position = pos

func move_to_position(target_position: Vector2i) -> void:
	var direction = target_position - current_position
	move_in_direction.emit(direction)
	
	var terrain_map: TerrainMap = Global.terrain_map
	var global_pos = terrain_map.map_to_local(current_position)
	var target_global_pos = terrain_map.map_to_local(target_position)
	
	var x_tween: Tween = get_tree().create_tween()
	x_tween.set_ease(ease)
	x_tween.set_trans(trans)
	x_tween.tween_property(actor, "position:x", target_global_pos.x, movement_duration)
	
	var midpoint = global_pos + (target_global_pos - global_pos) / 2
	
	var y_tween: Tween = get_tree().create_tween()
	y_tween.set_ease(ease)
	y_tween.set_trans(trans)
	y_tween.tween_property(actor, "position:y", midpoint.y - bounce_amount, movement_duration / 2)
	y_tween.tween_property(actor, "position:y", target_global_pos.y, movement_duration / 2)
	
	x_tween.finished.connect(set_current_position.bind(target_position))

func move_to_and_back(target_position: Vector2i) -> void:
	var direction = target_position - current_position
	move_in_direction.emit(direction)
	
	var terrain_map: TerrainMap = Global.terrain_map
	var global_pos = terrain_map.map_to_local(current_position)
	var target_global_pos = terrain_map.map_to_local(target_position)
	
	var x_tween: Tween = get_tree().create_tween()
	x_tween.set_ease(ease)
	x_tween.set_trans(trans)
	x_tween.tween_property(actor, "position:x", target_global_pos.x, movement_duration / 2)
	x_tween.tween_property(actor, "position:x", global_pos.x, movement_duration / 2)
	
	var midpoint = global_pos + (target_global_pos - global_pos) / 2
	
	var y_tween: Tween = get_tree().create_tween()
	y_tween.set_ease(ease)
	y_tween.set_trans(trans)
	y_tween.tween_property(actor, "position:y", midpoint.y - bounce_amount, movement_duration / 4)
	y_tween.tween_property(actor, "position:y", target_global_pos.y, movement_duration / 4)
	y_tween.tween_property(actor, "position:y", midpoint.y - bounce_amount, movement_duration / 4)
	y_tween.tween_property(actor, "position:y", global_pos.y, movement_duration / 4)
