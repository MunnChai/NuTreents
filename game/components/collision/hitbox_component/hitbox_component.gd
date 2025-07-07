class_name HitboxComponent
extends Area2D

@export var damage: float
@export var is_disabled: bool = false

signal hit_entity(entity: Node2D)

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if is_disabled:
		return
	
	if area is HurtboxComponent:
		area.hit_taken.emit(damage)
		
		var entity: Node2D = area.owner
		hit_entity.emit(entity)

func set_damage(new_damage: float) -> void:
	damage = new_damage

func get_damage() -> float:
	return damage

func disable() -> void:
	is_disabled = true

func enable() -> void:
	is_disabled = false
