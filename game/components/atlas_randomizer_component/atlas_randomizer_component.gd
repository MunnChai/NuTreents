class_name AtlasRandomizerComponent
extends Node2D

## If not set, this will automatically find the first sprite owned by the parent
@export var target: Sprite2D
@export var randomize_on_ready: bool = true

@export var randomize_x: bool = true
@export var randomize_y: bool = true

## Total number of horizontal sprites in the atlas texture
@export var atlas_h_size: int = 1
## Total number of vertical sprites in the atlas texture
@export var atlas_v_size: int = 1

## Desired number of randomized sprites, starting from the left
@export var h_frames: int = 1
## Desired number of randomized sprites, starting from the top
@export var v_frames: int = 1

@export var randomize_h_flip: bool = true
@export var randomize_v_flip: bool = false

func _ready() -> void:
	if not target:
		target = Components.get_component(get_parent(), Sprite2D)
	
	if not (target.texture is AtlasTexture):
		printerr("AtlasRandomizer used on non-AtlasTexture: ", owner.name, " - ", target.name)
		return
	
	if randomize_on_ready:
		randomize_sprite()

func randomize_sprite() -> void:
	var texture: AtlasTexture = target.texture
	
	if randomize_x:
		texture.region.size.x = texture.atlas.get_size().x / atlas_h_size
		var rand_x = randi_range(0, h_frames - 1)
		set_x_frame(rand_x)
	
	if randomize_y:
		texture.region.size.y = texture.atlas.get_size().y / atlas_v_size
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
