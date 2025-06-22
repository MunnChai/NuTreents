extends Node

## An autoload that keeps an editable dictionary
## with correspondence between TreeType and Twee PackedScenes
## Access using TreeRegistry

@export var twee_scene_registry: Dictionary[Global.TreeType, PackedScene]
var twee_stat_registry: Dictionary[Global.TreeType, TreeStatResource]

func _ready() -> void:
	_generate_twee_stat_registry()

func _generate_twee_stat_registry() -> void:
	for type: Global.TreeType in twee_scene_registry.keys():
		var temp_twee = get_new_twee(type)
		var stat_component: TweeStatComponent = Components.get_component(temp_twee, TweeStatComponent)
		twee_stat_registry[type] = stat_component.stat_resource
		temp_twee.free() ## IMPORTANT! Prevent memory leak

## Returns the packed scene asset for the given TreeType
func get_twee_packed_scene(type: Global.TreeType) -> PackedScene:
	return twee_scene_registry.get(type)

## Returns a new instantiated scene node of the given TreeType
func get_new_twee(type: Global.TreeType) -> Node2D:
	return get_twee_packed_scene(type).instantiate()

## Returns the stat resource for a given tree type
func get_twee_stat(type: Global.TreeType) -> TreeStatResource:
	return twee_stat_registry[type]
