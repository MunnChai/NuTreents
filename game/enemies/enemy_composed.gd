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
@onready var grid_range_component: GridRangeComponent = $GridRangeComponent
@onready var targeting_component: TargetingComponent = $TargetingComponent
@onready var action_timer: Timer = $ActionTimer

func _ready() -> void:
	add_to_group("enemies")


# Munn: This is where all the components get connected together? Seems weird...

func perform_action() -> void:
	# Target a tree
	var target_pos = targeting_component.get_nearest_tree_pos(grid_movement_component.current_position)
	
	if target_pos == null:
		return
	
	# Attack if in range
	if grid_range_component.is_in_range(grid_movement_component.current_position, target_pos):
		attack_tree(target_pos)
		return
	
	# If target tree is surrounded, get the best position
	if not MapUtility.is_tile_accessible(target_pos):
		target_pos = pathfinding_component.get_closest_valid_position(grid_movement_component.current_position, target_pos)
	
	move(target_pos)

# Munn: These could maybe be turned into states instead...? 
#region Actions

func attack_tree(target_pos: Vector2i) -> void:
	grid_movement_component.move_to_and_back(target_pos)

func move(target_pos: Vector2i) -> void:
	# Already there
	if grid_movement_component.current_position == target_pos:
		return
	
	# Find a path
	if not pathfinding_component.has_path():
		pathfinding_component.find_path(grid_movement_component.current_position, target_pos)
	
	# Get next position in the path
	var next_pos = pathfinding_component.get_next_position()
	
	if next_pos == null:
		return
	
	# If it is obstructed by a bug, find a new path
	if MapUtility.tile_has_entity(next_pos):
		pathfinding_component.find_path(grid_movement_component.current_position, target_pos)
		next_pos = pathfinding_component.get_next_position()
	
	if next_pos:
		pathfinding_component.pop_next_position()
		grid_movement_component.move_to_position(next_pos)

#endregion



func face_direction(direction: Vector2i):
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
