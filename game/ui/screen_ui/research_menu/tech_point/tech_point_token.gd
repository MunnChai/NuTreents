class_name TechPointToken
extends Node2D

@onready var background: Sprite2D = $Background

const EMERGE_DURATION: float = 0.75
const FLOAT_DURATION: float = 2.0

const Y_OFFSET: float = 40
const FLOAT_MAGNITUDE: float = 8

func play_acquire_animation() -> void:
	# Init tweens
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	# Init card
	background.visible = true
	background.scale = Vector2(0, 0)
	var init_pos = global_position
	
	# Emerge
	tween.set_parallel(true)
	tween.tween_property(background, "scale", Vector2(1, 1), EMERGE_DURATION)
	tween.tween_property(background, "global_position", init_pos + Vector2(0, -Y_OFFSET), EMERGE_DURATION)
	
	# Float
	tween.set_parallel(false)
	tween.tween_property(background, "global_position", Vector2(0, FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	tween.tween_property(background, "global_position", Vector2(0, -FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	tween.tween_property(background, "global_position", Vector2(0, FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	tween.tween_property(background, "global_position", Vector2(0, -FLOAT_MAGNITUDE), FLOAT_DURATION / 4).as_relative()
	
	# Disappear
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(background, "scale", Vector2(0, 0), EMERGE_DURATION)
	tween.tween_property(background, "global_position", init_pos, EMERGE_DURATION) # Ideally this tweens towards the tree menu
	tween.finished.connect(queue_free)
