extends Twee
class_name GrowthTree

var level: int

func _init(l: int, h: int, s: int, max: int, g: Vector3, m: int, p: Vector2):
	level = l
	super._init(h, s, max, g, m, p)
