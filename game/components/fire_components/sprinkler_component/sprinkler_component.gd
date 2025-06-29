class_name SprinklerComponent
extends Node2D

@export var grid_position_component: GridPositionComponent
@export var sprinkler_range_component: GridRangeComponent


func _ready() -> void:
	_get_components()

func _get_components() -> void:
	if not grid_position_component:
		grid_position_component = Components.get_component(get_owner(), GridPositionComponent)
	if not sprinkler_range_component:
		sprinkler_range_component = Components.get_component(get_owner(), GridRangeComponent)

func douse_surrounding_entities() -> void:
	var curr_pos: Vector2i = grid_position_component.get_pos()
	
	for offset in sprinkler_range_component.get_tiles_in_range():
		var true_pos: Vector2i = curr_pos + offset
		
		var entity: Node2D = MapUtility.get_entity_at(true_pos)
		if not entity:
			continue
		var flammable_component: FlammableComponent = Components.get_component(entity, FlammableComponent, "", true)
		if not flammable_component: 
			continue
		flammable_component.extinguish()
