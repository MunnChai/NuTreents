extends Structure
class_name City

var type: int # 1: Skyscraper; 2: general city tile; 3: Factory

func _init(t: int, p: Vector2):
	super._init(p)
	type = t

func breakdown() -> Ground:
	var fac = (type == 3)
	var ground = Ground.new(1, fac, pos)
	return ground
