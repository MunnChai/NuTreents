class_name TreeStatComponent
extends StatComponent

@export var tooltip_identifier_component: TooltipIdentifierComponent
@export var health_component: HealthComponent
@export var water_production_component: WaterProductionComponent
@export var nutreent_production_component: NutreentProductionComponent
@export var grow_timer: Timer

func _ready() -> void:
	var actor = get_parent()
	
	if not tooltip_identifier_component:
		tooltip_identifier_component = Components.get_component(actor, TooltipIdentifierComponent)
	if not health_component:
		health_component = Components.get_component(actor, HealthComponent)
	if not water_production_component:
		water_production_component = Components.get_component(actor, WaterProductionComponent)
	if not nutreent_production_component:
		nutreent_production_component = Components.get_component(actor, NutreentProductionComponent)
	if not grow_timer:
		grow_timer = Components.get_component(actor, Timer)
	
	#set_stats_from_resource()

func set_stats_from_resource(resource: StatResource = stat_resource) -> void:
	tooltip_identifier_component.set_id(resource.id)
	health_component.set_max_health(resource.hp)
	water_production_component.set_water_production(resource.gain.y - resource.maint)
	nutreent_production_component.set_nutreent_production(resource.gain.x)
	grow_timer.wait_time = resource.time_to_grow

func set_upgraded_stats_from_resource(resource: StatResource = stat_resource) -> void:
	tooltip_identifier_component.set_id(resource.id)
	health_component.set_max_health(resource.hp_2)
	water_production_component.set_water_production(resource.gain_2.y - resource.maint_2)
	nutreent_production_component.set_nutreent_production(resource.gain_2.x)
	grow_timer.wait_time = resource.time_to_grow_2
