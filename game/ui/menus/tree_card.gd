extends TextureButton

@export var water_plus_text: String
@export var sun_plus_text: String
@export var nutrients_plus_text: String
@export var water_min_text: String
@export var sun_min_text: String
@export var nutrients_min_text: String
@export var species_text: String

@onready var water_plus: Label = $WaterPlus
@onready var sun_plus: Label = $SunPlus
@onready var nutrients_plus: Label = $NutrientsPlus
@onready var water_min: Label = $WaterMin
@onready var sun_min: Label = $SunMin
@onready var nutrients_min: Label = $NutrientsMin
@onready var species: Label = $Species

func _ready() -> void:
	water_plus.text = water_plus_text
	sun_plus.text = sun_plus_text
	nutrients_plus.text = nutrients_plus_text
	water_min.text = water_min_text
	sun_min.text = sun_min_text
	nutrients_min.text = nutrients_min_text
	species.text = species_text
