extends Node

## An autoload that keeps an editable dictionary
## with correspondence between TreeType and Twee PackedScenes
## Access using TreeRegistry

@export var twee_scene_registry: Dictionary[Global.TreeType, PackedScene]

## Returns the packed scene asset for the given TreeType
func get_twee_packed_scene(type: Global.TreeType) -> PackedScene:
	return twee_scene_registry.get(type)

## Returns a new instantiated scene node of the given TreeType
func get_new_twee(type: Global.TreeType) -> Twee:
	return get_twee_packed_scene(type).instantiate()
