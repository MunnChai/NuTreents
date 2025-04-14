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

@onready var water_label: RichTextLabel = %WaterLabel
@onready var nutrients_label: RichTextLabel = %NutrientsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_ui()

# Updates the text of each label to show current resource values
func update_ui():
	if TreeManager.nutreents_gain != 0:
		nutrients_label.text = str(int(TreeManager.nutreents)) + " (" + _get_pos(TreeManager.nutreents_gain) + str(int(TreeManager.nutreents_gain)) + "/s)"
	else:
		nutrients_label.text = str(int(TreeManager.nutreents))

	if Cursor.instance != null:
		var highlighted_forest := TreeManager.get_forest_at(Cursor.instance.iso_position)
		if highlighted_forest != null:
			if highlighted_forest.water_gain == 0:
				water_label.text = str(int(highlighted_forest.water))
			elif highlighted_forest.water_gain < 0:
				water_label.text = "[color=ff5671][shake rate=50.0 level=10 connected=1]" + str(int(highlighted_forest.water)) + " (" + _get_pos(highlighted_forest.water_gain) + str(int(highlighted_forest.water_gain)) + "/s)" 
			else:
				water_label.text = str(int(highlighted_forest.water)) + " (" + _get_pos(highlighted_forest.water_gain) + str(int(highlighted_forest.water_gain)) + "/s)"
		else:
			water_label.text = ""
	else:
		water_label.text = ""

func _get_pos(gain: int) -> String:
	if gain >= 0:
		return "+"
	return ""

# Updates resource values + calls update_ui()
func add_resources(delta_water: int, delta_sunlight: int, delta_nutrients: int):
	water += delta_water
	sunlight += delta_sunlight
	nutrients += delta_nutrients
	update_ui()
