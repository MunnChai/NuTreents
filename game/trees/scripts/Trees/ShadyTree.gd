extends GrowthTree
class_name ShadyTree

const HP1 = 10
const GAIN1 = Vector3(5, 0, 0)
const GAIN1_BUFFED = Vector3(6, 0, 0)
const MAX_WATER1 = 1
const MAINT1 = 1

const HP2 = 20
const GAIN2 = Vector3(10, 2, 1)
const GAIN2_BUFFED = Vector3(15, 6, 1)
const MAX_WATER2 = 3
const MAINT2 = 0

func _init(s: int, p: Vector2):
	var g = GAIN1
	# TODO: if near tall things, changed g to buffed stats
	super._init(1, HP1, s, MAX_WATER1, g, MAINT1, p)

func upgrade() -> ShadyTree:
	var tree = ShadyTree.new(storage, pos)
	tree.level = 2
	tree.hp = HP2
	tree.max_water = MAX_WATER2
	tree.gain = GAIN2 # TODO: if near tall things, use buffed stats
	tree.maint = MAINT2
	return tree
