extends Structure
class_name Twee

var died: bool
var attackable: bool
var hp: int
var storage: int
var max_water: int
var gain: Vector3
var maint: int
var forest: int # forest id

func _init(h: int, s: int, max: int, g: Vector3, m: int, p: Vector2i, f: int):
	super._init(p)
	died = false
	attackable = true
	hp = h
	storage = s
	max_water = max
	gain = g
	maint = m
	forest = f


func die():
	died = true
	#TreeManager.tree_die(pos)
	
## update local storage and use water for maintainence
## returns the right amount of res to system
func update() -> Vector3:
	var prev = storage # record old storage number
	
	# add new water to storage, storage equals at most max_water
	storage = min(storage + gain.y, max_water)
	
	# take maint from storage
	if (storage >= maint):
		storage -= maint
	else:
		var f: Forest = TreeManager.get_forest(forest)
		if (!f.get_water(maint - storage)):
			# if game doesn't have enough water either
			hp -= 2
		else:
			# game has enough water
			storage = 0
	if (hp <= 0):
		die()
	var g = Vector3(gain.x, storage - prev, gain.z)
	return g

func update_maint():
	# TODO
	return

## Gets the four directly adjacent tiles next to this twee
## Override this if reachable tiles are different
func get_reachable_offsets() -> Array[Vector2i]:
	return [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
