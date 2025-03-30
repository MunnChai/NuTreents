extends Node2D
class_name Structure

var id: String
var pos: Vector2i

func _ready() -> void:
	id = "structure"

## Initalize the isometric position of this structure...
func init_pos(p: Vector2i):
	pos = p

## Returns the string id of this structure...
func get_id() -> String:
	return id

## Returns the "height" that the arrow cursor should be above this structure...
## One of "low", "medium", and "high".
func get_arrow_cursor_height() -> String:
	return "low"
