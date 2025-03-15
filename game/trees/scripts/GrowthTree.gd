extends Twee
class_name GrowthTree

var level: int

func _ready():
	super._ready()
	level = 1

func upgrade():
	level = 2
