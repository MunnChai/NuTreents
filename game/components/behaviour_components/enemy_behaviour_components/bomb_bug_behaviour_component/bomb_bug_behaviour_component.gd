class_name BombBugBehaviourComponent
extends EnemyBehaviourComponent

func _connect_component_signals() -> void:
	super._connect_component_signals()
	
	enemy_animation_component.exploded.connect(exploded)
	
	grid_movement_component.move_in_direction.connect(_moved)

func _moved(dir) -> void:
	SoundManager.play_oneshot(&"bomb_tick", global_position)

func attack_tree(target_pos: Vector2i) -> void:
	explode()


func explode() -> void:
	# plays explode animation
	enemy_animation_component.play_explode()
	
	
func exploded() -> void:
	SoundManager.play_oneshot(&"bomb_explode", global_position)
	# waits for explode animation to finish, then deals actual damage
	var aoe_component: AoeComponent = hitbox_component
	await aoe_component.explode(grid_position_component.get_pos())
	die()
