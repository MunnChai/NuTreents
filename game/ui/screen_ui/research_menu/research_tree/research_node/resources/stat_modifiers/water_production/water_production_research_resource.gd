class_name WaterProductionResearchResource
extends ResearchNodeResource

@export var water_production_increase: int = 2

func apply_research(node: Node2D) -> void:
	super.apply_research(node)
	
	var water_production_component: WaterProductionComponent = Components.get_component(node, WaterProductionComponent)
	if not water_production_component:
		return
	if water_production_component.get_water_production() <= 0:
		return
	
	water_production_component.increase_water_production(water_production_increase)
