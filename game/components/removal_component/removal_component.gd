## Used for freeing the parent node
class_name RemovalComponent
extends Node2D

@export var actor: Node2D

# Munn: Kinda just so I can free nodes without needing to write a dedicated script for that node...

func _ready() -> void:
	if not actor:
		actor = get_parent()

func free_actor() -> void:
	actor.queue_free()
