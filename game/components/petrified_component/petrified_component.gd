class_name PetrifiedComponent
extends Node2D



@export var sprite_shatter_component: SpriteShatterComponent
@export var sprite_2d: Sprite2D
@export var petrified_sprite_2d: Sprite2D

var actor: Node2D

func _ready() -> void:
	actor = get_owner()
	
	_get_components()
	_connect_signals()
	
	await get_tree().process_frame
	
	_set_sprite_textures()

func _get_components() -> void:
	if not sprite_shatter_component:
		sprite_shatter_component = Components.get_component(actor, SpriteShatterComponent, "", true)

func _connect_signals() -> void:
	pass

func _set_sprite_textures() -> void:
	if sprite_2d:
		petrified_sprite_2d.texture = sprite_2d.texture.duplicate()
	
	sprite_shatter_component.set_sprite_to_copy(petrified_sprite_2d)
	sprite_shatter_component.create_shatter_pieces()

func depetrify() -> void:
	sprite_shatter_component.shatter()
