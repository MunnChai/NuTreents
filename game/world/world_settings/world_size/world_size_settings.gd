class_name WorldSizeSettings
extends Resource

@export var world_size: WorldSettings.WorldSize

@export var map_size: Vector2i

@export_group("City Settings")
@export_range(3, 50, 1) var min_cities: int
@export_range(3, 50, 1) var max_cities: int
@export var city_distance_from_origin: int = map_size.x / 2.5
@export var num_city_drunkards: int = map_size.x / 3
@export var drunkard_lifetime: int = map_size.x / 4
@export_subgroup("Building Settings")
@export_range(0, 10000) var min_buildings_per_city: int
@export_range(0, 10000) var max_buildings_per_city: int
@export_subgroup("Road Settings")
@export var min_roads_per_city: int
@export var max_roads_per_city: int
@export var road_drunkard_lifetime: int
@export var min_road_length: int
@export var max_road_length: int

## Tests
@export_group("Highway Settings") 
# road stuff
const TARGETED_DRUNKARD_LIFETIME: int = 150
const TARGETED_NUM_DRUNKARDS: int = 3
const TARGETED_DRUNKARD_INTELLIGENCE: float = 0.85
