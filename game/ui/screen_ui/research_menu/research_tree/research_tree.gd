class_name ResearchTree
extends Control

static var instance: ResearchTree

@onready var root_node: ResearchNode = %RootNode
@onready var v_box_container: VBoxContainer = $VBoxContainer

var is_mouse_hovering: bool = false

func _ready() -> void:
	instance = self
	_connect_signals()
	update_unlockable_nodes()

func _connect_signals() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		research_node.unlocked.connect(update_unlockable_nodes.unbind(1)) # Update tree upon unlocking node

func update_unlockable_nodes() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node.state != ResearchNode.ResearchState.UNLOCKED:
			var required_nodes: Array = research_node.required_nodes
			
			var is_unlockable: bool = true
			for required_node in required_nodes:
				if required_node.state != ResearchNode.ResearchState.UNLOCKED:
					is_unlockable = false
					break
			
			if is_unlockable:
				research_node.state = ResearchNode.ResearchState.UNLOCKABLE

func get_research_nodes() -> Array[ResearchNode]:
	var research_nodes: Array[ResearchNode] = []
	
	var hboxes: Array = v_box_container.get_children()
	for hbox: HBoxContainer in hboxes:
		var nodes: Array = hbox.get_children()
		for node in nodes:
			# Ignore filler nodes
			if node is ResearchNode:
				research_nodes.append(node)
	
	return research_nodes
