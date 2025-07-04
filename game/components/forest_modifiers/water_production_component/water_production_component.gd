class_name WaterProductionComponent
extends Node2D

const ADJACENT_WATER_MULTIPLIER: float = 2

@export var water_production: float
@export var grid_position_component: GridPositionComponent
@export var grid_range_component: GridRangeComponent

func _ready() -> void:
	if not grid_position_component: 
		grid_position_component = Components.get_component(get_parent(), GridPositionComponent)
	if not grid_range_component:
		grid_range_component = Components.get_component(get_parent(), GridRangeComponent, "GridRangeComponent")

func set_water_production(new_production: float) -> void:
	water_production = new_production

func get_water_production() -> float:
	if is_water_adjacent():
		return max(0, water_production * ADJACENT_WATER_MULTIPLIER)
	
	return water_production * get_rain_multiplier()

func add_water_production(amount: float) -> float:
	water_production += amount
	
	return water_production

func multiply_water_production(multiplier: float) -> float:
	water_production *= multiplier
	
	return water_production

func is_water_adjacent() -> bool:
	for offset in grid_range_component.get_tiles_in_range():
		var coord = grid_position_component.get_pos() + offset
		
		var tile_type: int = Global.terrain_map.get_tile_biome(coord)
		
		if (tile_type == Global.terrain_map.TileType.WATER):
			return true
	
	return false

func get_rain_multiplier() -> float:
	if WeatherManager.instance.is_raining():
		return 1.5
	else:
		return 1.0
