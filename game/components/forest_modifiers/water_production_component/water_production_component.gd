class_name WaterProductionComponent
extends Node2D

@export var water_production: float

func set_water_production(new_production: float) -> void:
	water_production = new_production

func get_water_production() -> float:
	return water_production

func add_water_production(amount: float) -> float:
	water_production += amount
	
	return water_production

func multiply_water_production(multiplier: float) -> float:
	water_production *= multiplier
	
	return water_production
