class_name AttackResearchResource
extends ResearchNodeResource

@export var range_increase: int = 1

func apply_research(node: Node2D) -> void:
	super.apply_research(node)
	
	var attack_range_component: GridRangeComponent = Components.get_component(node, GridRangeComponent, "AttackRangeComponent")
	if attack_range_component:
		attack_range_component.range += range_increase
