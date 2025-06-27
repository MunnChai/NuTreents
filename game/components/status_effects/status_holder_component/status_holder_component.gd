class_name StatusHolderComponent
extends Node2D

const STATUS_EFFECT_ICON = preload("res://components/status_effects/status_holder_component/status_effect_icon.tscn")

@export var icon_y_offset: float = 8.0
@export var particle_y_offset: float = 0.0

var remaining_durations: Dictionary[StatusEffect, SceneTreeTimer]
var status_effect_icons: Dictionary[StatusEffect, Node2D]
var status_effect_particles: Dictionary[StatusEffect, GPUParticles2D]

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
	_add_particles(status_effect)

func remove_status_effect(status_effect: StatusEffect) -> void:
	if disabled:
		return
	
	status_effect.remove_status_effect(actor)
	_remove_status_effect_icon(status_effect)
	_remove_particles(status_effect)
	
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
	if not status_effect.effect_icon:
		return
	
	var icon = STATUS_EFFECT_ICON.instantiate()
	icon.texture = status_effect.effect_icon
	
	var sprite: Sprite2D = Components.get_component(actor, Sprite2D)
	if sprite:
		sprite.add_child(icon)
	else:
		add_child(icon)
	
	status_effect_icons[status_effect] = icon
	
	_fix_status_effect_offsets()

func _remove_status_effect_icon(status_effect: StatusEffect) -> void:
	if not status_effect_icons.has(status_effect):
		return
	
	var icon: Node2D = status_effect_icons[status_effect]
	
	var sprite: Sprite2D = Components.get_component(actor, Sprite2D)
	if sprite:
		sprite.remove_child(icon)
	else:
		remove_child(icon)
	
	status_effect_icons.erase(status_effect)
	
	_fix_status_effect_offsets()


const ICON_WIDTH: float = 14
func _fix_status_effect_offsets() -> void:
	var num_icons: int = status_effect_icons.size()
	if num_icons <= 0:
		return
	
	var total_x_offset: float = (num_icons - 1) * ICON_WIDTH
	var i: float = 0
	for icon: Node2D in status_effect_icons.values():
		var x_offset = (i * ICON_WIDTH) - (total_x_offset / 2)
		
		icon.position = Vector2(x_offset, -icon_y_offset)
		
		i += 1


#endregion



#region Icons

func _add_particles(status_effect: StatusEffect) -> void:
	if not status_effect.particles:
		return
	
	var particles = status_effect.particles.instantiate()
	
	add_child(particles)
	particles.emitting = true
	particles.global_position += Vector2(0, -particle_y_offset)
	
	status_effect_particles[status_effect] = particles

func _remove_particles(status_effect: StatusEffect) -> void:
	if not status_effect_particles.has(status_effect):
		return
	
	var particles: Node2D = status_effect_particles[status_effect]
	
	remove_child(particles)
	
	status_effect_particles.erase(status_effect)

#endregion



#region Durations

func _start_duration(status_effect: StatusEffect) -> void:
	var new_timer: SceneTreeTimer = get_tree().create_timer(status_effect.duration)
	new_timer.timeout.connect(remove_status_effect.bind(status_effect))
	
	remaining_durations[status_effect] = new_timer

func _renew_duration(status_effect: StatusEffect) -> void:
	if not remaining_durations.has(status_effect):
		return
	
	var timer: SceneTreeTimer = remaining_durations[status_effect]
	
	timer.set_time_left(status_effect.duration)

#endregion
