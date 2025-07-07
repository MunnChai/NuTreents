class_name SoundPlayer
extends AudioStreamPlayer2D

@onready var base_attenuation := attenuation
@onready var base_volume := volume_linear

func _ready() -> void:
	update_attributes()

func _process(delta: float) -> void:
	update_attributes()

func update_attributes() -> void:
	var zoom_level := Camera.instance.get_percent_zoom()
	
	attenuation = lerp(base_attenuation, base_attenuation * 2.0, zoom_level)
	volume_linear = lerp(base_volume * 0.5, base_volume, zoom_level)
