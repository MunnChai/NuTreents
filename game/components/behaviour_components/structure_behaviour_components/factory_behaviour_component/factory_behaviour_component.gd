class_name FactoryBehaviourComponent
extends StructureBehaviourComponent

const TECH_POINT_TOKEN = preload("res://ui/screen_ui/research_menu/tech_point/tech_point_token.tscn")

var tech_slot: int

@onready var destructable_component: DestructableComponent = $"../DestructableComponent"

func _ready():
	super._ready()
	
	if (Global.tech_menu.unassigned_tech.size() > 0):
		tech_slot = Global.tech_menu.unassigned_tech.pick_random()
		Global.tech_menu.unassigned_tech.erase(tech_slot)

func _get_components() -> void:
	super._get_components()
	
	if not destructable_component:
		destructable_component = Components.get_component(actor, DestructableComponent)

func _connect_signals() -> void:
	super._connect_signals()
	
	#destructable_component.destroyed.connect(create_factory_remains)
	destructable_component.destroyed.connect(_on_destroyed)

func _on_destroyed() -> void:
	ResearchTree.instance.add_tech_points(1)
	var tech_point_token = TECH_POINT_TOKEN.instantiate()
	Global.fog_map.add_child(tech_point_token)
	tech_point_token.global_position = global_position
	tech_point_token.play_acquire_animation()

## DEPRECATED
func create_factory_remains() -> void:
	# Get Factory remains node
	var factory_remains: Node2D = StructureRegistry.get_new_structure(Global.StructureType.FACTORY_REMAINS)
	
	var factory_remains_behaviour_component: FactoryRemainsBehaviourComponent = Components.get_component(factory_remains, FactoryRemainsBehaviourComponent)
	factory_remains_behaviour_component.tech_slot = tech_slot
	
	var grid_position_component: GridPositionComponent = Components.get_component(actor, GridPositionComponent)
	
	# Turn tile to dirt
	Global.terrain_map.set_cell_type(grid_position_component.get_pos(), Global.terrain_map.TileType.DIRT)
	
	# Create factory remains
	Global.structure_map.add_structure(grid_position_component.get_pos(), factory_remains)

func apply_data_resource(save_resource: Resource):
	super.apply_data_resource(save_resource)
	
	tech_slot = save_resource.tech_slot
