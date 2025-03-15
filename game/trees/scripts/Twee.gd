extends Structure
class_name Twee

var died: bool
var attackable: bool
var hp: int
var storage: int
var max_water: int
var gain: Vector3
var maint: int

func _ready():
	died = false
	attackable = true
	hp = 10
	storage = 0
	max_water = 0
	gain = Vector3(0, 0, 0)
	maint = 0
	
func _process(delta):
	update_gain()
	update_maint()

func die():
	died = true
	# TODO: update corresponding Tile.planted to false

func update_gain():
	# TODO
	return
	
func update_maint():
	# TODO
	return
