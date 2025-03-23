extends Node2D
class_name Structure

var id: String
var pos: Vector2i

func _ready() -> void:
	id = "structure"

func init_pos(p: Vector2i):
	pos = p

func get_id() -> String:
	return id
