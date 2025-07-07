class_name Lightning
extends Node2D

func _ready() -> void:
	strike()

func strike() -> void:
	## PLAY ANIMATION
	$AnimationPlayer.play("strike")
	SoundManager.play_oneshot(&"lightning_strike", global_position)
	await $AnimationPlayer.animation_finished
	queue_free()
