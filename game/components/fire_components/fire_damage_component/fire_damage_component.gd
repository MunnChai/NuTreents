class_name FireDamageComponent
extends Node2D

## Deals damage on fire tick

@export var flammable_component: FlammableComponent
@export var health_component: HealthComponent
@export var damage_amount: float = 3.0

func _ready() -> void:
	flammable_component.fire_tick.connect(_on_tick)
	
	if health_component == null:
		health_component = Components.get_component(get_owner(), HealthComponent, "", true)

func _on_tick() -> void:
	if health_component:
		health_component.subtract_health(damage_amount)
