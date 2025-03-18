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
	TreeManager.tree_die(pos)

# returns the right amount of resource to add to system
# if storage > max_water after a turn, return the amount that's added to storage
func get_gain() -> Vector3:
	storage += gain.y
	var g = Vector3(gain.x, min(gain.y, gain.y - (storage-max_water)), gain.z)
	storage = min(storage, max_water)
	return g
	
# take water to survie, either from own storage or other trees
# if insufficient water, deduct hp
func update_maint():
	#if (storage >= maint):
		#storage -= maint
	# ask TreeManager for water, if no water then deduct health
	# TODO: local storage not updated correctly
	var has_water = TreeManager.get_water(maint)
	if (!has_water):
		hp -= 2
	if (hp <= 0):
		die()
