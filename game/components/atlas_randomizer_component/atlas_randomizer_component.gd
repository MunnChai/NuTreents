class_name AtlasRandomizerComponent
extends Node2D

## If not set, this will automatically find the first sprite owned by the parent
@export var target: Sprite2D

@export var randomize_x: bool = true
@export var randomize_y: bool = true

@export var h_frames: int = 1
@export var v_frames: int = 1

@export var randomize_h_flip: bool = true
@export var randomize_v_flip: bool = false

func _ready() -> void:
	if not target:
		if Components.has_component(get_parent(), Sprite2D):
			target = Components.get_component(get_parent(), Sprite2D)
	
	if not (target.texture is AtlasTexture):
		printerr("AtlasRandomizer used on non-AtlasTexture: ", target.name, " - ", target)
		return
	
	var texture: AtlasTexture = target.texture.duplicate()
	
	if randomize_x:
		texture.region.size.x = texture.atlas.get_size().x / h_frames
		var rand_x = randi_range(0, h_frames - 1)
		set_x_frame(rand_x)
	
	if randomize_y:
		texture.region.size.y = texture.atlas.get_size().y / v_frames
		var rand_y = randi_range(0, v_frames - 1)
		set_y_frame(rand_y)
	
	if randomize_h_flip:
		target.flip_h = randf() > 0.5
	
	if randomize_v_flip:
		target.flip_v = randf() > 0.5
	
	target.texture = texture

func set_x_frame(frame: int):
	target.texture.region.position.x = frame * target.texture.region.size.x

func set_y_frame(frame: int):
	target.texture.region.position.y = frame * target.texture.region.size.y
