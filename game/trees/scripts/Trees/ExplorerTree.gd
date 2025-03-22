class_name ExplorerTree
extends Twee


func get_reachable_offsets() -> Array[Vector2i]:
	
	var reachable: Array[Vector2i] = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT,
		Vector2i.UP * 2, Vector2i.DOWN * 2, Vector2i.RIGHT * 2, Vector2i.LEFT * 2,
		Vector2i.UP + Vector2i.LEFT, Vector2i.UP + Vector2i.RIGHT,
		Vector2i.DOWN + Vector2i.LEFT, Vector2i.DOWN + Vector2i.RIGHT
		]
	
	return reachable
