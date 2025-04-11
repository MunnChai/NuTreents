extends Control

@export var tree_stat: TreeStatResource
@export var water_plus_text: String
@export var sun_plus_text: String
@export var nutrients_plus_text: String
@export var water_min_text: String
@export var sun_min_text: String
@export var nutrients_min_text: String
@export var species_text: String
@export var type: Global.TreeType

@export var texture: Texture2D

@onready var water_plus: Label = $TextureRect/WaterPlus
@onready var nutrients_plus: Label = $TextureRect/NutrientsPlus
@onready var water_min: Label = $TextureRect/WaterMin
@onready var nutrients_min: Label = $TextureRect/NutrientsMin
@onready var species: Label = $TextureRect/Species
@onready var cost = $TextureRect/Cost

func _ready() -> void:
	$TextureRect/TextureRect.texture = texture
	
	var net_water = tree_stat.gain_2.y - tree_stat.maint_2
	if (net_water > 0):
		water_plus.text = str(int(net_water))
		water_min.text = str(int(0))
	else:
		water_plus.text = str(int(0))
		water_min.text = str(int(abs(net_water)))
	
	nutrients_plus.text = str(int(tree_stat.gain_2.x))
	nutrients_min.text = str(int(0))
	species.text = tree_stat.name
	cost.text = "Cost: " + str(tree_stat.cost_to_purchase)

@onready var start_position = $TextureRect.position

func _process(delta: float) -> void:
	if TreeMenu.instance.get_currently_selected_tree_type() == type:
		$TextureRect.position = start_position + Vector2.UP * 8.0
	else:
		$TextureRect.position = start_position + Vector2.DOWN * 4.0

func _on_button_pressed() -> void:
	if TreeMenu.instance.get_currently_selected_tree_type() != type:
		TreeMenu.instance.currently_selected_tree = TreeMenu.instance.tree_order.find(type) 
		SfxManager.play_sound_effect("ui_click")


func _on_mouse_entered():
	InfoBox.get_instance().show_content_for_tree(tree_stat)

func _on_mouse_exited():
	InfoBox.get_instance().hide_content()
