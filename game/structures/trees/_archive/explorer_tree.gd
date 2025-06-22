class_name ExplorerTree
extends Twee

func _ready() -> void:
	super._ready()
	
	id = "explorer_tree"

func get_reachable_offsets() -> Array[Vector2i]:
	var reachable: Array[Vector2i] = []
	for x in range(-2, 3):
		for y in range(-2, 3):
			var pos = Vector2i(x, y)
			reachable.append(pos)
	
	return reachable
