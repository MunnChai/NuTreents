class_name EnemyBehaviourComponent
extends Node2D

# Components
@export_group("Components")
@export var health_component: HealthComponent
@export_subgroup("Animation")
@export var animation_player: AnimationPlayer
@export var sprite_2d: Sprite2D
@export_subgroup("Collision")
@export var hurtbox_component: HurtboxComponent
@export var hitbox_component: HitboxComponent
@export_subgroup("Movement")
@export var action_timer: Timer
@export var grid_position_component: GridPositionComponent
@export var grid_movement_component: GridMovementComponent
@export var targeting_component: TargetingComponent
@export var pathfinding_component: PathfindingComponent
@export var grid_range_component: GridRangeComponent
@export_subgroup("Other")
@export var popup_emitter_component: PopupEmitterComponent
@export var enemy_stat_component: EnemyStatComponent

## The node that this component is acting on, usually the parent
var actor: Node2D

func _ready() -> void:
	actor = get_parent()
	actor.add_to_group("enemies")
	
	_get_components()
	_connect_component_signals()

# Gets the components if they are not set in the editor
func _get_components() -> void:
	if not health_component:
		health_component = Components.get_component(actor, HealthComponent)
	
	if not animation_player:
		animation_player = Components.get_component(actor, AnimationPlayer)
	if not sprite_2d:
		sprite_2d = Components.get_component(actor, Sprite2D)
	
	if not hurtbox_component:
		hurtbox_component = Components.get_component(actor, HurtboxComponent)
	if not hitbox_component:
		hitbox_component = Components.get_component(actor, HitboxComponent)
	
	if not action_timer:
		action_timer = Components.get_component(actor, Timer)
	if not grid_position_component:
		grid_position_component = Components.get_component(actor, GridPositionComponent)
	if not grid_movement_component:
		grid_movement_component = Components.get_component(actor, GridMovementComponent)
	if not targeting_component:
		targeting_component = Components.get_component(actor, TargetingComponent)
	if not pathfinding_component:
		pathfinding_component = Components.get_component(actor, PathfindingComponent)
	if not grid_range_component:
		grid_range_component = Components.get_component(actor, GridRangeComponent)
	
	if not popup_emitter_component:
		popup_emitter_component = Components.get_component(actor, PopupEmitterComponent)
	if not enemy_stat_component:
		enemy_stat_component = Components.get_component(actor, EnemyStatComponent)


func _connect_component_signals() -> void:
	hurtbox_component.hit_taken.connect(health_component.subtract_health)
	hurtbox_component.hit_taken.connect(play_hurt_animation.unbind(1))
	
	health_component.health_subtracted.connect(popup_emitter_component.popup_number)
	health_component.died.connect(die)
	
	grid_movement_component.move_in_direction.connect(face_direction)
	
	action_timer.timeout.connect(perform_action)
	action_timer.one_shot = false
	action_timer.start()



## The main enemy behaviour function. This is called every time action_timer finishes
func perform_action() -> void:
	if health_component.is_dead:
		return
	
	# Target a tree
	var target_pos = targeting_component.get_nearest_tree_pos(grid_position_component.get_pos())
	
	if target_pos == null:
		return
	
	# Attack if in range
	if grid_range_component.is_in_range(grid_position_component.get_pos(), target_pos):
		attack_tree(target_pos)
		return
	
	# If target tree is surrounded, get the best position
	if not MapUtility.is_tile_accessible(target_pos):
		target_pos = pathfinding_component.get_closest_valid_position(grid_position_component.get_pos(), target_pos)
	
	move(target_pos)

# Munn: These could maybe be turned into states instead...? 
#region Actions

func attack_tree(target_pos: Vector2i) -> void:
	grid_movement_component.move_to_and_back(target_pos)

func move(target_pos: Vector2i) -> void:
	# Already there
	if grid_position_component.get_pos() == target_pos:
		return
	
	# Find a path
	if not pathfinding_component.has_path():
		pathfinding_component.find_path(grid_position_component.get_pos(), target_pos)
	
	# Get next position in the path
	var next_pos = pathfinding_component.get_next_position()
	
	if next_pos == null:
		return
	
	# If it is obstructed by a bug, find a new path
	if MapUtility.tile_has_entity(next_pos):
		pathfinding_component.find_path(grid_position_component.get_pos(), target_pos)
		next_pos = pathfinding_component.get_next_position()
	
	if next_pos:
		pathfinding_component.pop_next_position()
		grid_movement_component.move_to_position(next_pos)

#endregion

func die():
	hurtbox_component.monitorable = false
	hurtbox_component.monitoring = false
	hitbox_component.monitorable = false
	hitbox_component.monitoring = false
	
	match (enemy_stat_component.type):
		Global.EnemyType.SPEEDLE:
			SfxManager.play_sound_effect("speedle_die")
		Global.EnemyType.SILK_SPITTER:
			SfxManager.play_sound_effect("silk_spitter")
	
	animation_player.play("death")
	animation_player.animation_finished.connect(
		func(animation_name):
			queue_free()
	)

#region Animation

func play_hurt_animation():
	if animation_player.current_animation == "idle":
		animation_player.play("hurt")
		animation_player.queue("idle")
	elif animation_player.current_animation == "idle_backwards":
		animation_player.play("hurt_backwards")
		animation_player.queue("idle_backwards")

func face_direction(direction: Vector2i):
	if direction.length() > 1:
		direction.clamp(Vector2i(-1, -1), Vector2i(1, 1))
	
	match (direction):
		Vector2i.UP:
			sprite_2d.flip_h = true
			animation_player.play("idle_backwards")
		Vector2i.DOWN:
			sprite_2d.flip_h = true
			animation_player.play("idle")
		Vector2i.LEFT:
			sprite_2d.flip_h = false
			animation_player.play("idle_backwards")
		Vector2i.RIGHT:
			sprite_2d.flip_h = false
			animation_player.play("idle")

#endregion
