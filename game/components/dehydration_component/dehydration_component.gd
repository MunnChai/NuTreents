class_name DehydrationComponent
extends Node

## Component responsible for conveying particular dehydration data/behaviours for an entity

@export var twee_behaviour_component: TweeBehaviourComponent
@export var health_component: HealthComponent

@export var is_dehydrated := false ## Can we visually see that the trees are dehydrated?
@export var is_taking_damage := false ## Is this tree taking dehydration damage?

@export var dehydration_damage := 2

const WATER_DAMAGE_DELAY = 3.0
var water_damage_time := 0.0

func _ready() -> void:
	# Randomize water damage time
	water_damage_time += randf_range(WATER_DAMAGE_DELAY, WATER_DAMAGE_DELAY * 2)
	
	_get_components()

func _get_components() -> void:
	if not twee_behaviour_component:
		twee_behaviour_component = Components.get_component(get_owner(), TweeBehaviourComponent)
	if not health_component:
		health_component = Components.get_component(get_owner(), HealthComponent)

func _process(delta: float) -> void:
	if not twee_behaviour_component or not health_component or not twee_behaviour_component.grow_timer:
		return
	
	if twee_behaviour_component.water_production_component.is_water_adjacent():
		return
	
	if twee_behaviour_component.water_production_component.is_producing_water():
		return
	
	if is_dehydrated:
		twee_behaviour_component.grow_timer.paused = true
		twee_behaviour_component.is_dehydrated = true
	else:
		twee_behaviour_component.is_dehydrated = false
		twee_behaviour_component.grow_timer.paused = false
	
	if is_taking_damage:
		while (water_damage_time > WATER_DAMAGE_DELAY):
			health_component.subtract_health(dehydration_damage, null)
			water_damage_time -= randf_range(WATER_DAMAGE_DELAY, WATER_DAMAGE_DELAY * 2)
		water_damage_time += delta
