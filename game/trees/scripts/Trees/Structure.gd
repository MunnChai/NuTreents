extends Node2D
class_name Structure

var id: String
var pos: Vector2

func _init(p: Vector2):
	pos = p

func get_id() -> String:
	return id
