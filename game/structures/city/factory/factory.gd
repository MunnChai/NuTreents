class_name Factory
extends Structure

@onready var sprite_2d = $Sprite2D

@export var cost_to_remove: int = 0

var tech_slot: int

func _ready():
	var rand = randf()
	if (rand > 0.5):
		sprite_2d.flip_h = true
	
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
