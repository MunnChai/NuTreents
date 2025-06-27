class_name StatusHolderComponent
extends Node2D

const STATUS_EFFECT_ICON = preload("res://components/status_effects/status_holder_component/status_effect_icon.tscn")

@export var icon_y_offset: float = 16.0

var remaining_durations: Dictionary[StatusEffect, SceneTreeTimer]
var status_effect_icons: Dictionary[StatusEffect, Node2D]

var disabled: bool = false

var actor: Node2D

func _ready() -> void:
	actor = get_parent()


#region Public Functions

func add_status_effect(status_effect: StatusEffect) -> void:
	if disabled:
		return
	
	if remaining_durations.has(status_effect):
		_renew_duration(status_effect)
		return
	
	status_effect.apply_status_effect(actor)
	_start_duration(status_effect)
	_add_status_effect_icon(status_effect)

func remove_status_effect(status_effect: StatusEffect) -> void:
	if disabled:
		return
	
	status_effect.remove_status_effect(actor)
	_remove_status_effect_icon(status_effect)
	
	remaining_durations.erase(status_effect)

func remove_all_status_effects() -> void:
	if disabled:
		return
	
	for status_effect: StatusEffect in remaining_durations:
		status_effect.remove_status_effect(actor)
		_remove_status_effect_icon(status_effect)
	
	remaining_durations.clear()
	status_effect_icons.clear()

func enable() -> void:
	disabled = false

func disable() -> void:
	disabled = true

#endregion



#region Icons

func _add_status_effect_icon(status_effect: StatusEffect) -> void:
	var icon = STATUS_EFFECT_ICON.instantiate()
	icon.texture = status_effect.effect_icon
	
	add_child(icon)
	icon.global_position += Vector2(0, -icon_y_offset)
	
	status_effect_icons[status_effect] = icon

func _remove_status_effect_icon(status_effect: StatusEffect) -> void:
	var icon: Node2D = status_effect_icons[status_effect]
	
	remove_child(icon)

#endregion



#region Durations

func _start_duration(status_effect: StatusEffect) -> void:
	var new_timer: SceneTreeTimer = get_tree().create_timer(status_effect.duration)
	new_timer.timeout.connect(remove_status_effect.bind(status_effect))
	
	remaining_durations[status_effect] = new_timer

func _renew_duration(status_effect: StatusEffect) -> void:
	var timer: SceneTreeTimer = remaining_durations[status_effect]
	
	timer.set_time_left(status_effect.duration)

#endregion
