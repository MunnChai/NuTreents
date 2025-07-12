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
	# Add a safety check here as well.
	if not twee_scene_registry.has(type):
		printerr("TreeRegistry Error: Tried to get packed scene for an unknown tree type: ", type)
		return null
	return twee_scene_registry.get(type)

## Returns a new instantiated scene node of the given TreeType
func get_new_twee(type: Global.TreeType) -> Node2D:
	var packed_scene = get_twee_packed_scene(type)
	if packed_scene:
		return packed_scene.instantiate()
	return null # Return null if the packed scene doesn't exist

## Returns the stat resource for a given tree type
func get_twee_stat(type: Global.TreeType) -> TreeStatResource:
	# --- BUG FIX ---
	# Added a check to ensure the 'type' exists as a key in the dictionary
	# before trying to access it. This prevents the "Out of bounds" crash
	# when the function is called with an invalid type, like -1.
	if not twee_stat_registry.has(type):
		return null # Return null instead of crashing.
		
	return twee_stat_registry[type]
