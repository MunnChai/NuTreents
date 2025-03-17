extends Node
class_name tree_manager

# stores all trees
var tree_map: Dictionary[Vector2i, Node2D]

func add_tree(coords: Vector2i) -> bool:
	if (tree_map.has(coords)):
		upgrade_tree(coords)
	var tree = DefaultTree.new(0, coords)
	tree_map[coords] = tree
	return true
	
func upgrade_tree(coords: Vector2i) -> bool:
	if (!tree_map.has(coords)):
		return false
	var original_tree: DefaultTree = tree_map[coords]
	var new_tree: DefaultTree = original_tree.upgrade()
	tree_map.erase(coords)
	tree_map[coords] = new_tree
	
	original_tree.queue_free()
	return true
	
func remove_tree(coords: Vector2i) -> bool:
	if (!tree_map.has(coords)):
		return false
	var tree = tree_map[coords]
	tree_map.erase(coords)
	tree.queue_free()
	return true
