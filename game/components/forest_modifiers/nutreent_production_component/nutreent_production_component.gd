class_name NutreentProductionComponent
extends Node2D

@export var nutreent_production: float

func set_nutreent_production(new_production: float) -> void:
	nutreent_production = new_production

func get_nutreent_production() -> float:
	return nutreent_production

func add_nutreent_production(amount: float) -> float:
	nutreent_production += amount
	
	return nutreent_production

func multiply_nutreent_production(multiplier: float) -> float:
	nutreent_production *= multiplier
	
	return nutreent_production
