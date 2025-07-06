class_name HealthResearchResource
extends ResearchNodeResource

@export var health_increase: int = 10

func apply_research(node: Node2D) -> void:
	super.apply_research(node)
	
	var health_component: HealthComponent = Components.get_component(node, HealthComponent)
	if health_component:
		health_component.increase_max_health(health_increase)
