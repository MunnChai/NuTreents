extends Node
 


@export var world_size_settings: Dictionary[Global.WorldSize, WorldSizeSettings]

func get_world_size_settings(size: Global.WorldSize):
	return world_size_settings[size]
