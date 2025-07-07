class_name FireResistResearchResource
extends ResearchNodeResource

@export var fire_damage_decrease: int = 2

func apply_research(node: Node2D) -> void:
	super.apply_research(node)
	
	var fire_damage_component: FireDamageComponent = Components.get_component(node, FireDamageComponent, "", true)
	if not fire_damage_component:
		return
	
	fire_damage_component.increase_damage(-fire_damage_decrease)
