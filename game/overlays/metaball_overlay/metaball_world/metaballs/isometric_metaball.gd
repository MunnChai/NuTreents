class_name IsometricMetaball
extends Node2D

## ISOMETRIC METABALL for WATER/FOREST VIEW VIBES

var elapsed_time := 0.0
var origin := Vector2.ZERO

@onready var amplitude_multipliers := [randf_range(0.5, 2.0), randf_range(0.5, 2.0)]
@onready var frequency_multipliers := [randf_range(0.5, 2.0), randf_range(0.5, 2.0)]

func _ready() -> void:
	scale = Vector2.ZERO
	TweenUtil.scale_to(self, Vector2.ONE)

func _process(delta: float) -> void:
	elapsed_time += delta
	
	var shift := Vector2(sin(elapsed_time * frequency_multipliers[0]) * 2.0 * amplitude_multipliers[0], sin(elapsed_time * frequency_multipliers[1]) * 2.0 * amplitude_multipliers[1])
	position = origin + shift

var is_removed := false

func remove() -> void:
	if is_removed:
		return
	is_removed = true
	
	var tween := TweenUtil.scale_to(self, Vector2.ZERO)
	await tween.finished
	
	queue_free()
