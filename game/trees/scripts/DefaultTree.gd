extends GrowthTree
class_name DefaultTree

const GAIN1 = Vector3(5, 0, 0)
const MAX_WATER1 = 2
const MAINT1 = 2

const HP2 = 20
const GAIN2 = Vector3(10, 2, 1)
const MAX_WATER2 = 5
const MAINT2 = 0

func _ready():
	super._ready()
	gain = GAIN1
	max_water = MAX_WATER1
	maint = MAINT1

func upgrade():
	super.upgrade()
	hp = HP2
	gain = GAIN2
	max_water = MAX_WATER2
	maint = MAINT2
