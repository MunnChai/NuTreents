extends GrowthTree
class_name ShadyTree

const GAIN1 = Vector3(5, 0, 0)
const GAIN1_BUFFED = Vector3(6, 0, 0)
const MAX_WATER1 = 1
const MAINT1 = 1

const HP2 = 20
const GAIN2 = Vector3(10, 2, 1)
const GAIN2_BUFFED = Vector3(15, 6, 1)
const MAX_WATER2 = 3
const MAINT2 = 0

func _ready():
	super._ready()
	gain = GAIN1 # TODO: if near tall things, use buffed stats
	max_water = MAX_WATER1
	maint = MAINT1
	
func upgrade():
	super.upgrade()
	hp = HP2
	gain = GAIN2 # TODO: if near tall things, use buffed stats
	max_water = MAX_WATER2
	maint = MAINT2
