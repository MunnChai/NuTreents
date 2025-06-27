class_name FreezeStatusEffect
extends StatusEffect

func apply_status_effect(entity: Node2D) -> void:
	var action_timer: Timer = Components.get_component(entity, Timer, "ActionTimer")
	if action_timer != null:
		action_timer.wait_time += duration
		print(action_timer.wait_time)

func remove_status_effect(entity: Node2D) -> void:
	var action_timer: Timer = Components.get_component(entity, Timer, "ActionTimer")
	if action_timer != null:
		action_timer.wait_time -= duration
		action_timer.start()
