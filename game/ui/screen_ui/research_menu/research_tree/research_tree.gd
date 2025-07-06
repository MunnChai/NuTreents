class_name ResearchTree
extends Control

static var instance: ResearchTree

@onready var root_node: ResearchNode = %RootNode
@onready var v_box_container: VBoxContainer = $VBoxContainer

var num_tech_points: int = 0:
	set(new_tech_points):
		num_tech_points = new_tech_points
		num_tech_points_changed.emit(new_tech_points)

signal num_tech_points_changed(new_tech_points: int)
signal unlock_failed(research_node: ResearchNode)
signal unlock_success(research_node: ResearchNode)

func _ready() -> void:
	instance = self
	_connect_signals()
	update_unlockable_nodes()

func _connect_signals() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		research_node.try_unlocked.connect(try_unlock)
		research_node.unlocked.connect(update_unlockable_nodes.unbind(1)) # Update tree upon unlocking node

func try_unlock(research_node: ResearchNode) -> void:
	if num_tech_points >= research_node.research_resource.tech_point_cost:
		research_node.unlock_research_node()
		num_tech_points -= research_node.research_resource.tech_point_cost
		update_unlockable_nodes()
		unlock_success.emit(research_node)
	else:
		SfxManager.play_sound_effect("ui_fail")
		unlock_failed.emit(research_node)

func update_unlockable_nodes() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if not research_node.is_unlocked():
			var required_nodes: Array = research_node.required_nodes
			
			var is_unlockable: bool = true
			for required_node in required_nodes:
				if not required_node.is_unlocked():
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

func get_unlocked_nodes() -> Array[ResearchNode]:
	var unlocked_nodes: Array[ResearchNode]
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node.is_unlocked():
			unlocked_nodes.append(research_node)
	
	return unlocked_nodes

func set_unlocked_nodes(unlocked_node_ids: Array) -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node.research_resource.id in unlocked_node_ids:
			research_node.unlock_research_node()
	
	update_unlockable_nodes()

func reset_unlocked_nodes() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node == root_node:
			research_node.unlock_research_node()
		else:
			research_node.lock_research_node()
	
	update_unlockable_nodes()

func get_unlocked_node_ids() -> Array:
	var unlocked_nodes: Array[ResearchNode] = get_unlocked_nodes()
	var unlocked_ids: Array = unlocked_nodes.map(
		func(node: ResearchNode):
			return node.research_resource.id
	)
	return unlocked_ids

func get_root_node() -> ResearchNode:
	return root_node

func add_tech_points(amount: int) -> void:
	num_tech_points += amount

func set_tech_points(amount: int) -> void:
	num_tech_points = amount

func get_num_tech_points() -> int:
	return num_tech_points
