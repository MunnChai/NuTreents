class_name ProjectileSpawnerComponent
extends SpawnerComponent

@export var damage: float

func spawn_node(grid_offset: Vector2i = Vector2i.ZERO) -> Node2D:
	var current_position: GridPositionComponent = Components.get_component(get_parent(), GridPositionComponent)
	
	var new_spawn: Node2D = spawn.instantiate()
	add_child(new_spawn)
	
	if new_spawn.has_method("set_damage"):
		new_spawn.set_damage(damage)
	if Components.has_component(new_spawn, HitboxComponent):
		Components.get_component(new_spawn, HitboxComponent).set_damage(damage)
	
	return new_spawn


func set_damage(new_damage: float) -> void:
	damage = new_damage

func get_damage() -> float:
	return damage
