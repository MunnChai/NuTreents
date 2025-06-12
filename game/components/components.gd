class_name Components
extends Node

static func get_component(node: Node, component_type: Variant) -> Variant:
	if not node:
		return null
	
	var children = node.get_children()
	
	for child in children:
		if is_instance_of(child, component_type):
			return child
	
	return null

static func has_component(node: Node, component_type: Variant) -> bool:
	if not node:
		return false
	
	var children = node.get_children()
	
	for child in children:
		if is_instance_of(child, component_type):
			return true
	
	return false
