class_name HealthComponent 
extends Node2D

@export var max_health: float
var current_health: float
var is_dead: bool = false

var actor: Node2D

signal died()
signal health_added(amount: float)
signal health_subtracted(amount: float)

func _ready() -> void:
	actor = get_owner()
	current_health = max_health


func increase_max_health(amount: float, increase_current_health: bool = true) -> void:
	max_health += amount
	
	if increase_current_health:
		current_health += amount

func set_max_health(health: float) -> void:
	max_health = health
	set_current_health(health)

func get_max_health() -> float:
	return max_health

func set_current_health(health: float) -> void:
	current_health = health
	if current_health <= 0:
		current_health = 0
		is_dead = true
		died.emit()
	else:
		is_dead = false

func get_current_health() -> float:
	return current_health



func add_health(amount: float) -> float:
	current_health += amount
	health_added.emit(amount)
	
	if current_health > max_health:
		current_health = max_health
	
	if current_health > 0:
		is_dead = false
	
	return current_health

func subtract_health(amount: float) -> float:
	current_health -= amount
	health_subtracted.emit(amount)
	
	if current_health <= 0:
		current_health = 0
		is_dead = true
		died.emit()
	
	return current_health
