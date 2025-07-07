class_name ProjectileSpawnerComponent
extends SpawnerComponent

@export var damage: float

func spawn_node(grid_offset: Vector2i = Vector2i.ZERO, new_spawn: Node2D = null, parent: Node = null) -> Node2D:
	var current_position: GridPositionComponent = Components.get_component(get_parent(), GridPositionComponent)
	
	if new_spawn == null:
		new_spawn = spawn.instantiate()
	
	if parent != null:
		parent.add_child(new_spawn)
		new_spawn.global_position = global_position
	else:
		add_child(new_spawn)
	
	if new_spawn.has_method("set_damage"):
		new_spawn.set_damage(damage)
	if Components.has_component(new_spawn, HitboxComponent, "", true):
		Components.get_component(new_spawn, HitboxComponent, "", true).set_damage(damage)
	
	return new_spawn

func increase_damage(amount: float) -> void:
	damage += amount

func set_damage(new_damage: float) -> void:
	damage = new_damage

func get_damage() -> float:
	return damage
