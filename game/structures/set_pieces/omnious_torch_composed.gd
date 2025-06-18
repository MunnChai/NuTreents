class_name OmniousTorchComposed
extends Node2D

@export var type: Global.StructureType

@onready var sprite_2d: Sprite2D = %Sprite2D

#region Overrides

func get_arrow_cursor_height() -> String:
	return "high"

func apply_data_resource(save_resource: Resource):
	type = save_resource.type
	
	sprite_2d.flip_h = save_resource.flip_h
	
	if sprite_2d.texture is AtlasTexture:
		sprite_2d.texture.region.position = save_resource.texture_region_position

#endregion
