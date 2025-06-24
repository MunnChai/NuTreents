extends Node2D

const LIGHTNING = preload("res://events/weather/lightning/lightning.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lmb"):
		var new = LIGHTNING.instantiate()
		add_child(new)
		new.global_position = Vector2.ZERO + Vector2.UP * 27.0
