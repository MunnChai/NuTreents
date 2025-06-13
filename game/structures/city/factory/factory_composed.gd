class_name FactoryComposed
extends StructureComposed

var tech_slot

func _ready():
	# If tech_slots are still unassigned
	if (Global.tech_menu.unassigned_tech.size() > 0):
		tech_slot = Global.tech_menu.unassigned_tech.pick_random()
		Global.tech_menu.unassigned_tech.erase(tech_slot)
		#print("Assigned factory tech slot: ", tech_slot)

## Returns the "height" that the arrow cursor should be above this structure...
## One of "low", "medium", and "high".
func get_arrow_cursor_height() -> String:
	return "medium"

func apply_data_resource(save_resource: Resource):
	type = save_resource.type
	
	sprite_2d.flip_h = save_resource.flip_h
	
	tech_slot = save_resource.tech_slot
