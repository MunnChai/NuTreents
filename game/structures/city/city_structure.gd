class_name CityStructure
extends Structure

const OUTLINE_FADE_DURATION: float = 0.1

@onready var sprite_2d = $Sprite2D

var structure_type: Global.StructureType

var is_outline_active: bool = false


func _process(delta: float) -> void:
	if is_outline_active:
		show_outline(delta)
	else:
		hide_outline(delta)

func show_outline(delta: float):
	var current_alpha = (sprite_2d.get_material() as ShaderMaterial).get_shader_parameter("outline_alpha")
	var target_alpha = 1.0
	var lerped_alpha = lerp(current_alpha, target_alpha, delta / OUTLINE_FADE_DURATION)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("outline_alpha", lerped_alpha)

func hide_outline(delta: float):
	var current_alpha = (sprite_2d.get_material() as ShaderMaterial).get_shader_parameter("outline_alpha")
	var target_alpha = 0.0
	var lerped_alpha = lerp(current_alpha, target_alpha, delta / OUTLINE_FADE_DURATION)
	(sprite_2d.get_material() as ShaderMaterial).set_shader_parameter("outline_alpha", lerped_alpha)
