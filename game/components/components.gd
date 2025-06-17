class_name Components
extends Node

## Returns a node of the given type if it exists as a descendent of the given node, null otherwise
static func get_component(node: Node, component_type: Variant) -> Variant:
	if not node:
		return null
	
	return _search_for_component(node, component_type)

static func _search_for_component(node: Node, component_type: Variant) -> Variant:
	if is_instance_of(node, component_type):
		return node
	
	if node.get_child_count() == 0:
		return null
	
	var children = node.get_children()
	for child in children:
		if is_instance_of(child, component_type):
			return child
		else:
			var search = _search_for_component(child, component_type)
			if is_instance_of(search, component_type):
				return search
	
	return null

static func has_component(node: Node, component_type: Variant) -> bool:
	if not node:
		return false
	
	return get_component(node, component_type) != null
