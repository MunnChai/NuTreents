class_name EnemyAnimationComponent
extends Node2D

@export var animation_player: AnimationPlayer
@export var sprite_2d: Sprite2D

var actor: Node2D

func _ready() -> void:
	actor = get_parent()
	
	if not animation_player:
		animation_player = Components.get_component(actor, AnimationPlayer)
		animation_player.animation_finished.connect(_on_animation_finished)
	if not sprite_2d:
		sprite_2d = Components.get_component(actor, Sprite2D)

func play_hurt_animation():
	if animation_player.current_animation == "idle":
		animation_player.play("hurt")
	elif animation_player.current_animation == "idle_backwards":
		animation_player.play("hurt_backwards")

func play_death() -> void:
	animation_player.play("death")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hurt":
		animation_player.play("idle")
	if anim_name == "hurt_backwards":
		animation_player.play("idle_backwards")
	
	if anim_name == "death":
		actor.queue_free()

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
