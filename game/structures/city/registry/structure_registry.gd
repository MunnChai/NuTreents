extends Node

@export var structure_scene_registry: Dictionary[Global.StructureType, PackedScene]

func _ready() -> void:
	pass

## Returns the packed scene asset for the given StructureType
func get_structure_packed_scene(type: Global.StructureType) -> PackedScene:
	return structure_scene_registry.get(type)

## Returns a new instantiated scene node of the given StructureType
func get_new_structure(type: Global.StructureType) -> Structure:
	return get_structure_packed_scene(type).instantiate()
