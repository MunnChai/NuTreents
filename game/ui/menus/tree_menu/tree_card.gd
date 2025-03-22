extends Control

@export var water_plus_text: String
@export var sun_plus_text: String
@export var nutrients_plus_text: String
@export var water_min_text: String
@export var sun_min_text: String
@export var nutrients_min_text: String
@export var species_text: String
@export var type: TreeManager.TreeType

@onready var water_plus: Label = $TextureRect/WaterPlus
@onready var sun_plus: Label = $TextureRect/SunPlus
@onready var nutrients_plus: Label = $TextureRect/NutrientsPlus
@onready var water_min: Label = $TextureRect/WaterMin
@onready var sun_min: Label = $TextureRect/SunMin
@onready var nutrients_min: Label = $TextureRect/NutrientsMin
@onready var species: Label = $TextureRect/Species

func _ready() -> void:
	water_plus.text = water_plus_text
	sun_plus.text = sun_plus_text
	nutrients_plus.text = nutrients_plus_text
	water_min.text = water_min_text
	sun_min.text = sun_min_text
	nutrients_min.text = nutrients_min_text
	species.text = species_text

func _on_button_pressed() -> void:
	TreeManager.selected_tree_species = type
	print(str(type))
