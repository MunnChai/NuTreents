class_name StatusHolderComponent
extends Node2D

const SLOWING_STATUS_EFFECT = preload("res://components/status_effects/status_effect_resources/slowing_status_effect.tres")

var remaining_durations: Dictionary[StatusEffect, SceneTreeTimer]

var actor: Node2D

func _ready() -> void:
	actor = get_parent()



func add_status_effect(status_effect: StatusEffect) -> void:
	if remaining_durations.has(status_effect):
		renew_duration(status_effect)
		return
	
	status_effect.apply_status_effect(actor)
	start_duration(status_effect)

func remove_status_effect(status_effect: StatusEffect) -> void:
	status_effect.remove_status_effect(actor)
	
	remaining_durations.erase(status_effect)



func start_duration(status_effect: StatusEffect) -> void:
	var new_timer: SceneTreeTimer = get_tree().create_timer(status_effect.duration)
	new_timer.timeout.connect(remove_status_effect.bind(status_effect))
	
	remaining_durations[status_effect] = new_timer

func renew_duration(status_effect: StatusEffect) -> void:
	var timer: SceneTreeTimer = remaining_durations[status_effect]
	
	timer.set_time_left(status_effect.duration)
