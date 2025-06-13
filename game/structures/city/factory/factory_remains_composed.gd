class_name FactoryRemainsComposed
extends StructureComposed

var tech_slot: int

## Returns the "height" that the arrow cursor should be above this structure...
## One of "low", "medium", and "high".
func get_arrow_cursor_height() -> String:
	return "low"
