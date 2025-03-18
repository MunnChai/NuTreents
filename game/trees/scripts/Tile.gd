extends Node2D
class_name Tile

var pos: Vector2
var plantable: bool
var planted: bool

func _init(p: Vector2):
	pos = p
	plantable = false
	planted = false
	
func plant():
	if (not plantable):
		return false
	else:
		plantable = false
		planted = true
		return true
