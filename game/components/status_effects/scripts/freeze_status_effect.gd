class_name FreezeStatusEffect
extends StatusEffect

func apply_status_effect(entity: Node2D) -> void:
	var action_timer: Timer = Components.get_component(entity, Timer, "ActionTimer")
	if action_timer != null:
		action_timer.paused = true
	
	var animation_player: AnimationPlayer = Components.get_component(entity, AnimationPlayer)
	if animation_player:
		animation_player.pause()

func remove_status_effect(entity: Node2D) -> void:
	var action_timer: Timer = Components.get_component(entity, Timer, "ActionTimer")
	if action_timer != null:
		action_timer.paused = false
	
	var animation_player: AnimationPlayer = Components.get_component(entity, AnimationPlayer)
	if animation_player:
		animation_player.play()
