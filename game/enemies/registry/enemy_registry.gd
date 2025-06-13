extends Node2D

@export var enemy_scene_registry: Dictionary[Global.EnemyType, PackedScene]
var enemy_stat_registry: Dictionary[Global.EnemyType, EnemyStatResource]

func _ready() -> void:
	_generate_enemy_stat_registry()

func _generate_enemy_stat_registry() -> void:
	for type: Global.EnemyType in enemy_scene_registry.keys():
		var temp_enemy = get_new_enemy(type)
		enemy_stat_registry[type] = temp_enemy.enemy_stat
		temp_enemy.free() ## IMPORTANT! Prevent memory leak

## Returns the packed scene asset for the given EnemyType
func get_enemy_packed_scene(type: Global.EnemyType) -> PackedScene:
	return enemy_scene_registry.get(type)

## Returns a new instantiated scene node of the given EnemyType
func get_new_enemy(type: Global.EnemyType) -> EnemyComposed:
	return get_enemy_packed_scene(type).instantiate()

## Returns the stat resource for a given enemy type
func get_enemy_stat(type: Global.EnemyType) -> EnemyStatResource:
	return enemy_stat_registry[type]
