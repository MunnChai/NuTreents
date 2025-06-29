class_name DestructableComponent
extends Node2D

@export var cost_to_destroy: float
@export var remove_self_on_destroyed: bool = true

signal destroyed()

func get_cost() -> float:
	return cost_to_destroy

func destroy():
	if remove_self_on_destroyed:
		var grid_position_component = Components.get_component(get_owner(), GridPositionComponent)
		Global.structure_map.remove_structure(grid_position_component.get_pos())
		print("REMOVED!")
	
	destroyed.emit()
