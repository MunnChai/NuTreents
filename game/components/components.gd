class_name Components
extends Node

## Returns a node of the given type if it exists as a descendent of the given node, null otherwise
static func get_component(node: Node, component_type: Variant, string_name: String = "", call_recursive: bool = false) -> Variant:
	if not node:
		return null
	
	return _search_for_component(node, component_type, string_name, call_recursive)

static func _search_for_component(node: Node, component_type: Variant, string_name: String = "", call_recursive: bool = false) -> Variant:
	# Check self
	if string_name != "":
		if is_instance_of(node, component_type) and node.name == string_name:
			return node
	else:
		if is_instance_of(node, component_type):
			return node
	
	# No children and self is not node
	if node.get_child_count() == 0:
		return null
	
	# Loop over children
	var children = node.get_children()
	for child in children:
		if string_name != "":
			if is_instance_of(child, component_type) and child.name == string_name:
				return child
		else:
			if is_instance_of(child, component_type):
				return child
	
	if not call_recursive:
		return null
	
	# Recurse over grandchildren
	children = node.get_children()
	for child in children:
		var result = _search_for_component(child, component_type)
		if string_name != "":
			if is_instance_of(result, component_type) and result.name == string_name:
				return result
		else:
			if is_instance_of(result, component_type):
				return result
	
	return null

static func has_component(node: Node, component_type: Variant, string_name: String = "", call_recursive: bool = false) -> bool:
	if not node:
		return false
	
	return get_component(node, component_type, string_name, call_recursive) != null
