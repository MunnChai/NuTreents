class_name HitboxComponent
extends Area2D

@export var damage: float

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		area.hit_taken.emit(damage)

func set_damage(new_damage: float) -> void:
	damage = new_damage

func get_damage() -> float:
	return damage
