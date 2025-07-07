class_name TweeStatComponent
extends StatComponent

@export var type: Global.TreeType

@export_group("General Components")
@export var tooltip_identifier_component: TooltipIdentifierComponent
@export var health_component: HealthComponent
@export var water_production_component: WaterProductionComponent
@export var nutreent_production_component: NutreentProductionComponent
@export var grow_timer: Timer

@export_group("Attack Components")
## The attack_damage_node requires a set_damage() function
@export var attack_damage_node: Node
@export var attack_range_node: GridRangeComponent
@export var attack_cooldown_timer: Timer

var actor: Node2D

func _ready() -> void:
	actor = get_parent()
	
	_get_components()

func _get_components() -> void:
	if not tooltip_identifier_component:
		tooltip_identifier_component = Components.get_component(actor, TooltipIdentifierComponent)
	if not health_component:
		health_component = Components.get_component(actor, HealthComponent)
	if not water_production_component:
		water_production_component = Components.get_component(actor, WaterProductionComponent)
	if not nutreent_production_component:
		nutreent_production_component = Components.get_component(actor, NutreentProductionComponent)
	if not grow_timer:
		grow_timer = Components.get_component(actor, Timer, "GrowTimer")

func set_stats_from_resource(resource: StatResource = stat_resource) -> void:
	tooltip_identifier_component.set_id(resource.id)
	health_component.set_max_health(resource.hp)
	water_production_component.set_water_production(resource.gain.y - resource.maint)
	nutreent_production_component.set_nutreent_production(resource.gain.x)
	if grow_timer:
		grow_timer.wait_time = resource.time_to_grow
	
	if attack_damage_node:
		attack_damage_node.set_damage(resource.attack_damage)
	if attack_range_node:
		attack_range_node.range = resource.attack_range
	if attack_cooldown_timer:
		attack_cooldown_timer.wait_time = resource.attack_cooldown
	
	ResearchTree.instance.apply_all_research(actor)

func set_upgraded_stats_from_resource(resource: StatResource = stat_resource) -> void:
	tooltip_identifier_component.set_id(resource.id)
	health_component.set_max_health(resource.hp_2)
	water_production_component.set_water_production(resource.gain_2.y - resource.maint_2)
	nutreent_production_component.set_nutreent_production(resource.gain_2.x)
	
	if attack_damage_node:
		attack_damage_node.set_damage(resource.attack_damage_2)
	if attack_range_node:
		attack_range_node.range = resource.attack_range_2
	if attack_cooldown_timer:
		attack_cooldown_timer.wait_time = resource.attack_cooldown_2
	
	ResearchTree.instance.apply_all_research(actor)
