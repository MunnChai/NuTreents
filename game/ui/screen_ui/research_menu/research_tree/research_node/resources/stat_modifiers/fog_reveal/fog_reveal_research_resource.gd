class_name FogRevealResearchResource
extends ResearchNodeResource

@export var fog_range_increase: int = 1

func apply_research(node: Node2D) -> void:
	super.apply_research(node)
	
	var fog_reveal_component: FogRevealerComponent = Components.get_component(node, FogRevealerComponent)
	if not fog_reveal_component:
		return
	
	var fog_range_component: GridRangeComponent = fog_reveal_component.reveal_range_component
	if not fog_range_component:
		return
	
	fog_range_component.increase_range(fog_range_increase)
	
	var grid_position_component: GridPositionComponent = Components.get_component(node, GridPositionComponent)
	if not grid_position_component:
		return
	
	# Update fog
	Global.fog_map.remove_fog_around(grid_position_component.get_pos(), fog_reveal_component)
