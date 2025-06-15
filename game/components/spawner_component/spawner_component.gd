class_name SpawnerComponent
extends Marker2D

@export var spawn: PackedScene

func spawn_node(grid_offset: Vector2i = Vector2i.ZERO) -> Node2D:
	var current_position: GridPositionComponent = Components.get_component(get_parent(), GridPositionComponent)
	
	var new_spawn: Node2D = spawn.instantiate()
	add_child(new_spawn)
	
	return new_spawn
