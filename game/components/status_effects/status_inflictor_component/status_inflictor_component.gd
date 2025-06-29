class_name StatusInflictorComponent
extends Node2D

@export var status_effect: StatusEffect

func apply_status_effect(entity: Node2D) -> void:
	
	var status_holder_component: StatusHolderComponent = Components.get_component(entity, StatusHolderComponent)
	if status_holder_component != null:
		status_holder_component.add_status_effect(status_effect)
