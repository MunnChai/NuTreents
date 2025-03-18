extends Tile
class_name Ground

var type: int # 1: dirt; 2: grass; 3: water
var growth_time: float
var prev_fac: bool

func _init(t: int, fac: bool, p: Vector2):
	super._init(p)
	type = t
	growth_time = 1
	prev_fac = fac

func grass_countdown():
	# TODO: start countdown to grass tile
	return

func make_grass():
	if (type != 1):
		return
	type = 2
	growth_time = 1.5
