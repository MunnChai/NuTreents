extends Structure
class_name Twee

var died: bool
var attackable: bool
var hp: int
var storage: int
var max_water: int
var gain: Vector3
var maint: int

func _init(h: int, s: int, max: int, g: Vector3, m: int, p: Vector2i):
	super._init(p)
	died = false
	attackable = true
	hp = h
	storage = s
	max_water = max
	gain = g
	maint = m


func die():
	died = true

# returns gain so that system know how much resources should be added to total
func get_gain() -> Vector3:
	return gain
	
# take water to survie, either from own storage or other trees
# if insufficient water, deduct hp
func update_maint():
	if (storage >= maint):
		storage -= maint
	# ask TreeManager for water, if no water then deduct health
	var has_water = TreeManager.get_water(maint)
	if (!has_water):
		hp -= 5
	if (hp <= 0):
		die()
