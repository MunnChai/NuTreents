class_name DestructableComponent
extends Node2D

@export var cost_to_destroy: float

signal destroyed()

func get_cost() -> float:
	return cost_to_destroy

func destroy():
	destroyed.emit()
