class_name SpawnerComponent
extends Marker2D

@export var spawn: PackedScene

@onready var actor: Node2D = get_parent()

func spawn_node(grid_offset: Vector2i = Vector2i.ZERO) -> Node2D:
	var current_position: GridPositionComponent = Components.get_component(actor, GridPositionComponent)
	
	var new_spawn: Node2D = spawn.instantiate()
	add_child(new_spawn)
	
	if Components.has_component(new_spawn, GridPositionComponent):
		Components.get_component(new_spawn, GridPositionComponent).init_pos(current_position.get_pos())
	
	return new_spawn
