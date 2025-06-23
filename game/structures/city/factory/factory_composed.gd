class_name FactoryComposed
extends StructureComposed

var tech_slot: int

func _ready():
	if (Global.tech_menu.unassigned_tech.size() > 0):
		tech_slot = Global.tech_menu.unassigned_tech.pick_random()
		Global.tech_menu.unassigned_tech.erase(tech_slot)

func apply_data_resource(save_resource: Resource):
	type = save_resource.type
	
	sprite_2d.flip_h = save_resource.flip_h
	
	tech_slot = save_resource.tech_slot
