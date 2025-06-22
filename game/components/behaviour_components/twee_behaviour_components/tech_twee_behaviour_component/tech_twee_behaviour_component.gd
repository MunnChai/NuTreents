class_name TechTweeBehaviourComponent
extends TweeBehaviourComponent

var tech_slot: int

func remove():
	await super.remove() # Frees itself
	
	# Instantiate factory remains again
	var factory_remains: Node2D = StructureRegistry.get_new_structure(Global.StructureType.FACTORY_REMAINS)
	
	var factory_remains_behaviour_component: FactoryRemainsBehaviourComponent = Components.get_component(factory_remains, FactoryRemainsBehaviourComponent)
	factory_remains_behaviour_component.tech_slot = tech_slot
	
	var grid_position_component: GridPositionComponent = Components.get_component(actor, GridPositionComponent)
	Global.structure_map.add_structure(grid_position_component.get_pos(), factory_remains)
	
	if is_large:
		Global.tech_menu.current_tech.erase(tech_slot)

func upgrade_tree() -> void:
	super.upgrade_tree()
	
	# Do stuff related to TechMenu
	Global.tech_menu.current_tech.append(tech_slot)

func apply_data_resource(tree_resource: Resource):
	super.apply_data_resource(tree_resource)
	
	tech_slot = tree_resource.tech_slot
	if is_large:
		Global.tech_menu.current_tech.append(tech_slot)
