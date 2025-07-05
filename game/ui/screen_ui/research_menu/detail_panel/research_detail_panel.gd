class_name ResearchDetailPanel
extends Control

@onready var display_name: RichTextLabel = %DisplayName
@onready var icon: TextureRect = %Icon
@onready var description: RichTextLabel = %Description

func _ready() -> void:
	reset_details()

func set_details(research_node: ResearchNode) -> void:
	if research_node == null:
		reset_details()
		return
	
	var research_resource: ResearchNodeResource = research_node.research_resource
	if not research_resource:
		printerr("Error: ResearchNode missing ResearchNodeResource! ", research_node)
		reset_details()
		display_name.text = "ERR: Missing Resource"
		return
	
	display_name.text = research_resource.display_name
	icon.texture = research_resource.icon
	description.text = research_resource.description

func reset_details() -> void:
	display_name.text = "Select a Node to Research"
	icon.texture = null
	description.text = ""
