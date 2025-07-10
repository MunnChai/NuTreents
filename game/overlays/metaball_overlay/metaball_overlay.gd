class_name MetaballOverlay
extends Node2D

static var instance: MetaballOverlay ## Pseudo singleton access
static func is_instanced() -> bool:
	return is_instance_valid(instance)

@export var copy_camera: Camera2D

func _ready() -> void:
	instance = self
	layers.set(0, $MetaballLayer)

func _process(delta: float) -> void:
	if copy_camera:
		for layer: MetaballLayer in layers.values():
			layer.world.copy_camera = copy_camera
			global_position = copy_camera.global_position # Keep center on the camera that we are following

func add_metaball(pos: Vector2, layer_id: int = 0) -> IsometricMetaball:
	var layer := get_layer_or_create(layer_id)
	return layer.add_metaball(pos)

const METABALL_LAYER = preload("./metaball_layer/metaball_layer.tscn")
var layers: Dictionary[int, MetaballLayer] = {}
func add_new_layer(id: int) -> MetaballLayer:
	var layer := METABALL_LAYER.instantiate()
	add_child(layer)
	layer.position = Vector2.ZERO
	layer.set_color(Color.RED)
	layers.set(id, layer)
	return layer

func get_layer_or_create(id: int) -> MetaballLayer:
	if layers.has(id):
		return layers.get(id)
	return add_new_layer(id)
