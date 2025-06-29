class_name MortarTweeBehaviourComponent
extends GunTweeBehaviourComponent

@export var reload_animation_duration: float = 1.0

func perform_action() -> void:
	if not is_large:
		return
	
	# Check for enemies in range
	var current_position = grid_position_component.get_pos()
	var target_enemy = targeting_component.get_nearest_enemy(current_position)
	if not target_enemy:
		return
	
	var target_enemy_pos: Vector2i = Components.get_component(target_enemy, GridPositionComponent).get_pos()
	
	if attack_range_component.is_in_range(current_position, target_enemy_pos):
		tree_animation_component.play_custom_animation("shoot")
		await get_tree().create_timer(shoot_animation_delay).timeout # Munn: KINDA SCUFFED...
		spawn_projectile(target_enemy_pos)
		await get_tree().create_timer(action_timer.wait_time - reload_animation_duration - shoot_animation_delay).timeout
		tree_animation_component.play_custom_animation("reload")
