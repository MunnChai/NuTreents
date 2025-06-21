class_name EnemyStatResource
extends StatResource

@export var name: String
@export var id: String
@export_multiline var description: String

@export_category("In Game Stats")
@export var hp: float
@export var action_cooldown: float
@export var attack_damage: float
@export var attack_range: int

@export_category("Spawning Properties")
## The earliest day that this enemy will spawn
@export var earliest_spawn_day: int = 1
## Used to choose a set of enemies using a weighted random algorithm. 
## Higher weight means this enemy will show up more often.
@export var spawn_weight: int = 100
@export var spawn_point_cost: int = 5
