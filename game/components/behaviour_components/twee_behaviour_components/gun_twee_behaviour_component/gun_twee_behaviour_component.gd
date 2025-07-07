class_name GunTweeBehaviourComponent
extends TweeBehaviourComponent

@export var shoot_animation_delay: float = 0.25

@export var attack_range_component: GridRangeComponent
@export var targeting_component: TargetingComponent
@export var action_timer: Timer
@export var spawner_component: ProjectileSpawnerComponent

func _get_components() -> void:
	super._get_components()
	
	if not attack_range_component:
		attack_range_component = Components.get_component(actor, GridRangeComponent, "AttackRangeComponent")
	if not targeting_component:
		targeting_component = Components.get_component(actor, TargetingComponent)
	if not action_timer:
		action_timer = Components.get_component(actor, Timer, "ActionTimer")
	if not spawner_component:
		spawner_component = Components.get_component(actor, SpawnerComponent)

func _connect_component_signals() -> void:
	super._connect_component_signals()
	
	action_timer.timeout.connect(perform_action)
	action_timer.one_shot = false
	await get_tree().create_timer(randf_range(0, action_timer.wait_time)).timeout
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
		tree_animation_component.play_custom_animation("shoot")
		await get_tree().create_timer(shoot_animation_delay).timeout # Munn: KINDA SCUFFED...
		spawn_projectile(target_enemy_pos)

func spawn_projectile(target_pos: Vector2i) -> void:
	var bullet = spawner_component.spawn_node(Vector2(0, 0), null, Global.fog_map)
	
	var position_component: GridPositionComponent = Components.get_component(bullet, GridPositionComponent)
	position_component.init_pos(grid_position_component.get_pos())
	
	var movement_component: GridMovementComponent = Components.get_component(bullet, GridMovementComponent)
	movement_component.move_to_position(target_pos)
	
	SfxManager.play_sound_effect("gun_tree_projectile")
