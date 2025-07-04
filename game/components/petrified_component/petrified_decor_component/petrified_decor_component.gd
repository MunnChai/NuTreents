class_name PetrifiedDecorComponent
extends PetrifiedComponent

const PETRIFIED_TREE = preload("res://structures/set_pieces/petrified_trees/petrified_tree.gdshader")

@export var sprite_2d: Sprite2D

func _ready() -> void:
	super._ready()

func _get_components() -> void:
	if not sprite_2d:
		sprite_2d = Components.get_component(get_parent(), Sprite2D)

func petrify(override_flag: bool = false) -> void:
	if not depetrified and not override_flag:
		return
	
	depetrified = false
	
	if sprite_2d:
		sprite_2d.material = ShaderMaterial.new()
		sprite_2d.material.shader = PETRIFIED_TREE

func depetrify(override_flag: bool = false) -> void:
	if depetrified and not override_flag:
		return
	super.depetrify()
	
	if sprite_2d:
		var sprite_material = sprite_2d.material
		if sprite_material is ShaderMaterial:
			sprite_2d.material = null
