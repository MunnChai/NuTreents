class_name ResearchNodeResource
extends Resource

@export var display_name: String
@export var id: String
@export var icon: Texture2D
@export var tech_point_cost: int = 1
@export var tree_type: Global.TreeType = Global.TreeType.MOTHER_TREE
@export_multiline var description: String

func apply_research(node: Node2D) -> void:
	print("Applying research \"", display_name, "\" to: ", node)
	pass
