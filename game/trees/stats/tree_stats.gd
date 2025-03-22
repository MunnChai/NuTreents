class_name TreeStatResource
extends Resource

@export var name: String
@export_multiline var description: String

@export_group("PrimaryTreeStats")
@export var hp: int
@export var max_water: int
@export var gain: Vector3
@export var maint: int
@export var time_to_grow: float
@export var cost_to_purchase: int

@export_group("SecondaryTreeStats")
@export var hp_2: int
@export var max_water_2: int
@export var gain_2: Vector3
@export var maint_2: int
@export var time_to_grow_2: float
@export var cost_to_purchase_2: int
