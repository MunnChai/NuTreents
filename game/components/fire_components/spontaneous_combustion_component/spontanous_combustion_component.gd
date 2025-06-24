class_name SpontaneousCombustionComponent
extends Node2D

## RNG IGNITION

@export var flammable_component: FlammableComponent
@export var is_active := true ## Should try and combust?
@export var tick_duration: float = 1.0 ## Time between update
@export var percent_chance: float = 0.3 ## Per tick

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	$Timer.timeout.connect(_on_timeout)
	$Timer.start(tick_duration)

func _on_timeout() -> void:
	var rng_value = rng.randf_range(0.0, 1.0)
	
	if rng_value < percent_chance and is_active:
		flammable_component.ignite()
	
	$Timer.start(tick_duration)
