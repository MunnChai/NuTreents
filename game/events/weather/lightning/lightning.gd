class_name Lightning
extends Node2D

func _ready() -> void:
	strike()

func strike() -> void:
	## PLAY ANIMATION
	$AnimationPlayer.play("strike")
	await $AnimationPlayer.animation_finished
	queue_free()
