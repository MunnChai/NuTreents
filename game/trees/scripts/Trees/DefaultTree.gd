extends GrowthTree
class_name DefaultTree

const HP1 = 10
const GAIN1 = Vector3(5, 0, 0)
const MAX_WATER1 = 2
const MAINT1 = 2

const HP2 = 20
const GAIN2 = Vector3(10, 2, 1)
const MAX_WATER2 = 5
const MAINT2 = 0

func _init(s: int, p: Vector2):
	super._init(1, HP1, s, MAX_WATER1, GAIN1, MAINT1, p)

func upgrade() -> DefaultTree:
	var tree = DefaultTree.new(storage, pos)
	tree.level = 2
	tree.hp = HP2
	tree.max_water = MAX_WATER2
	tree.gain = GAIN2
	tree.maint = MAINT2
	return tree
