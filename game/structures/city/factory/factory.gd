class_name Factory
extends CityStructure

@export var cost_to_remove: int = 0

var tech_slot: int

func _ready():
	super._ready()
	
	var rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
	structure_type = Global.StructureType.FACTORY
	id = "factory"
	
	# If tech_slots are still unassigned
	if (Global.tech_menu.unassigned_tech.size() > 0):
		tech_slot = Global.tech_menu.unassigned_tech.pick_random()
		Global.tech_menu.unassigned_tech.erase(tech_slot)
		print("Assigned factory tech slot: ", tech_slot)

## Returns the "height" that the arrow cursor should be above this structure...
## One of "low", "medium", and "high".
func get_arrow_cursor_height() -> String:
	return "medium"

func apply_data_resource(save_resource: Resource):
	structure_type = save_resource.type
	
	sprite_2d.flip_h = save_resource.flip_h
	
	tech_slot = save_resource.tech_slot
