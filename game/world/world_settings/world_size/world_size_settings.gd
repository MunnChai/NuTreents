class_name WorldSizeSettings
extends Resource
 
## Default settings are the "Small" world size settings, so you can adjust based on that 

@export var world_size: Global.WorldSize

@export var map_size: Vector2i = Vector2i(40, 40)

@export_group("Spawn Settings")
@export var num_spawn_drunkards: int = 25
@export var spawn_drunkard_lifetime: int = 10

@export_group("Set Pieces") 
@export var num_tree_unlock_set_pieces: int = 5
@export var num_tech_point_set_pieces: int = 5
@export var set_piece_radiuses: Array[float] = [9, 16]
@export var num_set_pieces_per_circle: Array[int] = [4, 6]


@export_group("City Settings")
@export_range(3, 50, 1) var min_cities: int = 3
@export_range(3, 50, 1) var max_cities: int = 5
@export var city_distance_from_origin: int = 16
@export var num_city_drunkards: int = 13
@export var city_drunkard_lifetime: int = 10
@export_subgroup("Building Settings")
@export_range(0, 10000) var building_frequency: float = 0.4
@export_subgroup("Road Settings")
@export var min_roads_per_city: int = 3
@export var max_roads_per_city: int = 4
@export var road_drunkard_lifetime: int = 7
@export var min_road_length: int = 3
@export var max_road_length: int = 5
 
# Munn: I'm calling the dirt roads between cities "highways"
@export_group("Highway Settings") 
@export var num_highway_drunkards: int = 3
@export var highway_drunkard_lifetime: int = 100
@export var highway_drunkard_accuracy: float = 0.85 
