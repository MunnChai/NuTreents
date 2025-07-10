class_name MetaballOverlay
extends Node2D

static var instance: MetaballOverlay ## Pseudo singleton access
static func is_instanced() -> bool:
	return is_instance_valid(instance)

@export var copy_camera: Camera2D

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	if copy_camera:
		%MetaballWorld.copy_camera = copy_camera
		global_position = copy_camera.global_position # Keep center on the camera that we are following

func add_metaball(pos: Vector2) -> IsometricMetaball:
	return %MetaballWorld.add_metaball(pos)

## TODO: Multiple layer support
