class_name EnemyComposed
extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

# Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var popup_emitter_component: PopupEmitterComponent = $PopupEmitterComponent
@onready var pathfinding_component: PathfindingComponent = $PathfindingComponent
@onready var grid_movement_component: GridMovementComponent = $GridMovementComponent
@onready var grid_position_component: GridPositionComponent = $GridPositionComponent
@onready var grid_range_component: GridRangeComponent = $GridRangeComponent
@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var action_timer: Timer = $ActionTimer


@export var type: EnemyManager.EnemyType

func _ready() -> void:
	add_to_group("enemies")


# Munn: This is where all the components get connected together? Seems weird...

func perform_action() -> void:
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

func play_hurt_animation():
	if animation_player.current_animation == "idle":
		animation_player.play("hurt")
		animation_player.queue("idle")
	elif animation_player.current_animation == "idle_backwards":
		animation_player.play("hurt_backwards")
		animation_player.queue("idle_backwards")

func die():
	match (type):
		EnemyManager.EnemyType.SPEEDLE:
			SfxManager.play_sound_effect("speedle_die")
		EnemyManager.EnemyType.SILK_SPITTER:
			SfxManager.play_sound_effect("silk_spitter")
	
	animation_player.play("death")
	animation_player.animation_finished.connect(
		func(animation_name):
			queue_free()
	)

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
