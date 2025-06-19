class_name StructureBehaviourComponent
extends Node2D

@export var type: Global.StructureType

@export_group("Components")
@export var sprite_2d: Sprite2D

var actor: Node2D

func _ready() -> void:
	actor = get_parent()
	_get_components()
	_connect_signals()

func _get_components() -> void:
	if not sprite_2d:
		sprite_2d = Components.get_component(actor, Sprite2D)

func _connect_signals() -> void:
	pass

func apply_data_resource(save_resource: Resource):
	type = save_resource.type
	
	sprite_2d.flip_h = save_resource.flip_h
	
	if sprite_2d.texture is AtlasTexture:
		sprite_2d.texture.region.position = save_resource.texture_region_position
