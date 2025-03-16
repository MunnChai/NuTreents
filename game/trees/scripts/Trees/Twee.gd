extends Structure
class_name Twee

var died: bool
var attackable: bool
var hp: int
var storage: int
var max_water: int
var gain: Vector3
var maint: int

func _init(h: int, s: int, max: int, g: Vector3, m: int, p: Vector2):
	super._init(p)
	died = false
	attackable = true
	hp = h
	storage = s
	max_water = max
	gain = g
	maint = m


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
