extends GrowthTree
class_name DefaultTree

func _ready():
	super._ready()
	gain = Vector3(5, 0, 0)
	max_water = 2
	maint = 2

func upgrade():
	super.upgrade()
	hp = 20
	gain = Vector3(10, 2, 1)
	max_water = 5
	maint = 0
