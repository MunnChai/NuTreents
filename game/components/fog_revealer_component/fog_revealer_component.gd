class_name FogRevealerComponent
extends Node2D

@export var transparency_level: FogMap.TransparencyLevel = FogMap.TransparencyLevel.CLEAR
@export var update_surrounding: bool = true

@export var reveal_range_component: GridRangeComponent
