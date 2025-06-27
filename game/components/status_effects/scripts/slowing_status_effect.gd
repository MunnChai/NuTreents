class_name SlowingStatusEffect
extends StatusEffect

@export var slow_multiplier: float = 0.5

func apply_status_effect(entity: Node2D) -> void:
	super.apply_status_effect(entity)
	
	var action_timer: Timer = Components.get_component(entity, Timer, "ActionTimer")
	if action_timer != null:
		action_timer.wait_time /= slow_multiplier
	
	var grid_movement_component: GridMovementComponent = Components.get_component(entity, GridMovementComponent)
	if grid_movement_component != null:
		grid_movement_component.movement_duration /= slow_multiplier
	
	var animation_player: AnimationPlayer = Components.get_component(entity, AnimationPlayer)
	if animation_player != null:
		animation_player.speed_scale *= slow_multiplier


func remove_status_effect(entity: Node2D) -> void:
	super.remove_status_effect(entity)
	
	var action_timer = Components.get_component(entity, Timer, "ActionTimer")
	if action_timer != null:
		action_timer.wait_time *= slow_multiplier
	
	var grid_movement_component: GridMovementComponent = Components.get_component(entity, GridMovementComponent)
	if grid_movement_component != null:
		grid_movement_component.movement_duration *= slow_multiplier
	
	var animation_player: AnimationPlayer = Components.get_component(entity, AnimationPlayer)
	if animation_player != null:
		animation_player.speed_scale /= slow_multiplier
