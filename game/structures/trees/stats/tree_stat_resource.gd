class_name TreeStatResource
extends StatResource

@export var name: String
@export var id: String
@export_multiline var description: String

@export_group("TreeCard")
@export var tree_icon: Texture2D
@export var tree_icon_small: Texture2D
@export var special_card_background_override: Texture2D

@export_group("PrimaryTreeStats")
@export_subgroup("General")
@export var hp: int
@export var max_water: int
@export var gain: Vector3
@export var maint: int
@export var time_to_grow: float
@export var cost_to_purchase: int
@export_subgroup("Attacks")
@export var attack_damage: float
@export var attack_range: int
@export var attack_cooldown: float


@export_group("SecondaryTreeStats")
@export_subgroup("General")
@export var hp_2: int
@export var max_water_2: int
@export var gain_2: Vector3
@export var maint_2: int
@export var time_to_grow_2: float
@export var cost_to_purchase_2: int
@export_subgroup("Attacks")
@export var attack_damage_2: float
@export var attack_range_2: int
@export var attack_cooldown_2: float
