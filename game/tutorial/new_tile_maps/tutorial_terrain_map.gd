class_name TutorialTerrainMap
extends TerrainMap

func _ready() -> void:
	await get_tree().process_frame
	
	y_sort_enabled = true
