class_name EnemyComposed
extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

# Components
@onready var action_timer = $ActionTimer
@onready var health_component = $HealthComponent
@onready var hurtbox_component = $HurtboxComponent
@onready var hitbox_component = $HitboxComponent
@onready var popup_emitter_component = $PopupEmitterComponent
@onready var pathfinding_component = $PathfindingComponent
@onready var grid_movement_component = $GridMovementComponent
@onready var grid_range_component = $GridRangeComponent
@onready var targeting_component = $TargetingComponent


func _ready() -> void:
	add_to_group("enemies")


# Munn: I put stuff that I felt didn't really fit in a specific component here

func perform_action() -> void:
	# Target a new tree
	targeting_component.get_nearest_tree(grid_movement_component.current_position)
	if not targeting_component.currently_targeting:
		return
	if (targeting_component.currently_targeting as Twee).died:
		return
	
	var target_tree: Twee = (targeting_component.currently_targeting as Twee)
	
	if grid_range_component.is_in_range(grid_movement_component.current_position, target_tree.get_pos()):
		var next_pos = pathfinding_component.get_next_position(grid_movement_component.current_position, target_tree.get_pos(), false)
		grid_movement_component.move_to_and_back(next_pos)
	else:
		var next_pos = pathfinding_component.get_next_position(grid_movement_component.current_position, target_tree.get_pos())
		grid_movement_component.move_to_position(next_pos)


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
