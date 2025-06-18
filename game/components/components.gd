class_name Components
extends Node

## Returns a node of the given type if it exists as a descendent of the given node, null otherwise
static func get_component(node: Node, component_type: Variant, string_name: String = "") -> Variant:
	if not node:
		return null
	
	return _search_for_component(node, component_type, string_name)

static func _search_for_component(node: Node, component_type: Variant, string_name: String = "") -> Variant:
	if is_instance_of(node, component_type):
		return node
	
	if node.get_child_count() == 0:
		return null
	
	var children = node.get_children()
	for child in children:
		if string_name != "":
			if is_instance_of(child, component_type) and child.name == string_name:
				return child
			else:
				var result = _search_for_component(child, component_type)
				if is_instance_of(result, component_type) and result.name == string_name:
					return result
		else:
			if is_instance_of(child, component_type):
				return child
			else:
				var result = _search_for_component(child, component_type)
				if is_instance_of(result, component_type):
					return result
	
	return null

static func has_component(node: Node, component_type: Variant, string_name: String = "") -> bool:
	if not node:
		return false
	
	return get_component(node, component_type, string_name) != null
