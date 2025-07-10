class_name MetaballWorld
extends Node2D

static var instance: MetaballWorld

@onready var camera_2d: Camera2D = %Camera2D

func _ready() -> void:
	instance = self

#static func set_camera_global_position(pos: Vector2) -> void:
	#if instance:
		#instance.camera_2d.global_position = pos

static func set_camera_zoom(zoom: Vector2) -> void:
	#if instance:
		#instance.camera_2d.zoom = zoom
	pass

const ISOMETRIC_METABALL = preload("res://overlays/metaballs_overlay/isometric_metaball.tscn")
static func add_metaball(pos: Vector2) -> void:
	var new_ball := ISOMETRIC_METABALL.instantiate()
	instance.add_child(new_ball)
	new_ball.global_position = pos
	new_ball.origin = pos

func _process(delta: float) -> void:
	camera_2d.global_position = Camera.instance.global_position
