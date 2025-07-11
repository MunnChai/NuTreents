class_name WaterCapacityComponent
extends Node

## Specifies the water capacity that this entity should contribute to a forest

signal capacity_changed(old: float, new: float)
signal capacity_increased(change: float)
signal capacity_decreased(change: float)

@export var current_capacity := 0.0

func _ready() -> void:
	capacity_changed.connect(_on_capacity_changed)

func _on_capacity_changed(old: float, new: float) -> void:
	if old < new:
		capacity_increased.emit(new - old)
	elif old > new:
		capacity_decreased.emit(old - new)

## Immediately assigns the given capacity to the capacity
func set_capacity(new_capacity: float) -> void:
	var old := current_capacity
	current_capacity = new_capacity
	capacity_changed.emit(old, current_capacity)

## Returns the current capacity
func get_capacity() -> float:
	return current_capacity

## Gets the percent that this capacity is of a total capacity value
func get_percent_of_total_capacity(total_capacity: float) -> float:
	return current_capacity / total_capacity
