class_name MetaballLayer
extends Node2D

@onready var world: MetaballWorld = %MetaballWorld

var id: int = -1

func _ready() -> void:
	var gradient: GradientTexture1D = $SubViewportContainer.get_material().get_shader_parameter(&"gradient")
	gradient = gradient.duplicate(true)
	$SubViewportContainer.get_material().set_shader_parameter(&"gradient", gradient)

func add_metaball(pos: Vector2) -> IsometricMetaball:
	return world.add_metaball(pos)

@export var my_color: Color
func set_color(color: Color) -> void:
	if color != my_color:
		my_color = color
	
		var gradient: GradientTexture1D = $SubViewportContainer.get_material().get_shader_parameter(&"gradient")
		gradient.gradient.colors = [Color.TRANSPARENT, Color(my_color, 0.55)]
		$SubViewportContainer.get_material().set_shader_parameter(&"gradient", gradient)
func get_color() -> Color:
	return my_color
