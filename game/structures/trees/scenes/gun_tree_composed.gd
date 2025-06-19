class_name GunTweeComposed
extends TweeComposed

@onready var attack_range_component: GridRangeComponent = $AttackRangeComponent
@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var action_timer: Timer = $ActionTimer
@onready var spawner_component: SpawnerComponent = $SpawnerComponent

var damage: float

func _connect_component_signals() -> void:
	super._connect_component_signals()
	
	action_timer.timeout.connect(perform_action)
	action_timer.one_shot = false
	action_timer.start()

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
		play_shoot_animation()
		await get_tree().create_timer(0.25).timeout # Munn: KINDA SCUFFED...
		spawn_projectile(target_enemy_pos)

func spawn_projectile(target_pos: Vector2i) -> void:
	var bullet = spawner_component.spawn_node()
	
	var position_component: GridPositionComponent = Components.get_component(bullet, GridPositionComponent)
	position_component.init_pos(grid_position_component.get_pos())
	
	var movement_component: GridMovementComponent = Components.get_component(bullet, GridMovementComponent)
	movement_component.move_to_position(target_pos)
	
	var hitbox_component: HitboxComponent = Components.get_component(bullet, HitboxComponent)
	hitbox_component.set_damage(damage)
	
	SfxManager.play_sound_effect("gun_tree_projectile")

func play_shoot_animation() -> void:
	animation_player.play("shoot")
	animation_player.queue("large")

#region Overrides

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	super._on_animation_player_animation_finished(anim_name)
	if (anim_name == "shoot"):
		play_large_tree_animation()

func set_stats_from_resource(tree_stat: TreeStatResource):
	super.set_stats_from_resource(tree_stat)
	damage = tree_stat.damage
	action_timer.wait_time = tree_stat.attack_cooldown

func set_upgraded_stats_from_resource(tree_stat: TreeStatResource):
	super.set_stats_from_resource(tree_stat)
	damage = tree_stat.damage_2
	action_timer.wait_time = tree_stat.attack_cooldown_2

func get_uv_y_offset() -> float:
	if is_large:
		if animation_player.current_animation.get_basename() == "shoot":
			return 1.0
		else:
			return 0.45
	else:
		return 0.75

#endregion
