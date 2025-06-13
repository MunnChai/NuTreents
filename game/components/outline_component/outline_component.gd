class_name OutlineComponent
extends Node2D

const OUTLINE_SHADER: Shader = preload("res://ui/cursor/world_cursor/visual_cursor/outline.gdshader")

@export var actor: Sprite2D

@export var outline_color: Color = Color(1, 1, 1, 1)
@export var outline_width: int = 1
@export var outline_fade_duration: float = 0.1

var is_outline_active: bool = false

func _ready() -> void:
	if not actor:
		if Components.has_component(get_parent(), Sprite2D):
			actor = Components.get_component(get_parent(), Sprite2D)
		else:
			return
	
	if not actor.material:
		actor.material = ShaderMaterial.new()
		actor.material.shader = OUTLINE_SHADER
	else:
		actor.material = actor.material.duplicate()

func _process(delta: float) -> void:
	if actor.material is ShaderMaterial:
		lerp_outline(delta)

func show_outline() -> void:
	is_outline_active = true

func hide_outline() -> void:
	is_outline_active = false

func lerp_outline(delta: float) -> void:
	var target_alpha: float
	if is_outline_active:
		target_alpha = 1.0
	else:
		target_alpha = 0.0
	
	var material = (actor.get_material() as ShaderMaterial)
	var current_alpha = material.get_shader_parameter("outline_alpha")
	if current_alpha == null:
		return
	if is_equal_approx(current_alpha, target_alpha):
		return
	var lerped_alpha = lerp(current_alpha, target_alpha, delta / outline_fade_duration)
	(actor.get_material() as ShaderMaterial).set_shader_parameter("outline_alpha", lerped_alpha)
