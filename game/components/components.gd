class_name Components
extends Node

static func get_component(node: Node, component_type: Variant, recursive: bool = true) -> Variant:
	if not node:
		return null
	
	if recursive:
		return _search_for_component(node, component_type)
	
	var children = node.get_children()
	for child in children:
		if is_instance_of(child, component_type):
			return child
	
	return null

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
	
	var children = node.get_children()
	
	for child in children:
		if is_instance_of(child, component_type):
			return true
	
	return false
