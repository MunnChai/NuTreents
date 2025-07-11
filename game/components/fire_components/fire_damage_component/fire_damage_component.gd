class_name FireDamageComponent
extends Node2D

signal damage_tick

@export var flammable_component: FlammableComponent
@export var health_component: HealthComponent
@export var damage_amount: float = 3.0

func _ready() -> void:
	if not is_instance_valid(flammable_component):
		printerr("FireDamageComponent Error: FlammableComponent is not assigned.")
		return
		
	flammable_component.fire_tick.connect(_on_tick)
	
	if health_component == null:
		health_component = Components.get_component(get_owner(), HealthComponent, "", true)

func _on_tick() -> void:
	if not is_instance_valid(health_component): return

	var owner = get_parent()
	var final_damage = damage_amount

	if Components.has_component(owner, TweeStatComponent):
		var stat_comp: TweeStatComponent = Components.get_component(owner, TweeStatComponent)
		if stat_comp.type == Global.TreeType.ICY_TREE or stat_comp.type == Global.TreeType.SLOWING_TREE:
			final_damage *= 1.5 

	var fire_node = flammable_component.get_fire()
	health_component.subtract_health(final_damage, fire_node)
	damage_tick.emit()
