class_name DestructableComponent
extends Node2D

@export var cost_to_destroy: float

signal destroyed()

func destroy():
	destroyed.emit()
