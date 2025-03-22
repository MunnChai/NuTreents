extends Control

# Resource tracking vars
var water: int = 100
var sunlight: int = 50
var nutrients: int = 200

# Resource generation vars, would be changed based off # of trees/types of trees
var water_per_s: float = 1
var sun_per_s: float = 1
var nutrients_per_s: float = 1

var seconds: float = 0

@onready var water_label: Label = $WaterLabel
@onready var sun_label: Label = $SunLabel
@onready var nutrients_label: Label = $NutrientsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_ui()

# Updates the text of each label to show current resource values
func update_ui():
	water_label.text = str(int(TreeManager.res.y)) + " (+" + str(int(TreeManager.gain.y)) + "/s)"
	sun_label.text = str(int(TreeManager.res.z)) + " (+" + str(int(TreeManager.gain.z)) + "/s)"
	nutrients_label.text = str(int(TreeManager.res.x)) + " (+" + str(int(TreeManager.gain.x)) + "/s)"

# Updates resource values + calls update_ui()
func add_resources(delta_water: int, delta_sunlight: int, delta_nutrients: int):
	water += delta_water
	sunlight += delta_sunlight
	nutrients += delta_nutrients
	update_ui()
