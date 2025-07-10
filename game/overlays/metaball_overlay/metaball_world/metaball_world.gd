class_name MetaballWorld
extends Node2D

## METABALL WORLD
## I'm a metaball
## In a metaball world

## - The "world" beneath the metaball viewport
## - Matches the metaball camera with the given "real world" copy camera

@export var copy_camera: Camera2D ## The camera to copy from
@onready var camera: Camera2D = %MetaballCamera

const ISOMETRIC_METABALL = preload("./metaballs/isometric_metaball.tscn")
func add_metaball(pos: Vector2) -> IsometricMetaball:
	print("HI")
	var new_ball := ISOMETRIC_METABALL.instantiate()
	add_child(new_ball)
	new_ball.global_position = pos
	new_ball.origin = pos
	return new_ball

func _process(delta: float) -> void:
	if copy_camera:
		camera.global_position = copy_camera.global_position
