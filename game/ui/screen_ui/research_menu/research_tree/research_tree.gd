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
	
	await get_tree().process_frame
	
	DebugConsole.register("tech_points", func(args: PackedStringArray):
		num_tech_points += 1000000000
		, "Gives you a lot of tech points")

func _connect_signals() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		research_node.try_unlocked.connect(try_unlock)
		research_node.unlocked.connect(update_unlockable_nodes.unbind(1)) # Update tree upon unlocking node


## Try to unlock the given research node. Will succeed if the current num_tech_points > the node's cost
func try_unlock(research_node: ResearchNode) -> void:
	if num_tech_points >= research_node.research_resource.tech_point_cost:
		var notification = Notification.new(&"unlock", '[color=6be1e3]' + tr(&"NOTIF_TECH_UNLOCK").format({ "tech_name": research_node.research_resource.display_name.to_upper() }), { "priority": 3, "time_remaining": 3.0 });
		NotificationLog.instance.add_notification(notification)
		
		research_node.unlock_research_node()
		num_tech_points -= research_node.research_resource.tech_point_cost
		update_unlockable_nodes()
		unlock_success.emit(research_node)
		SoundManager.play_global_oneshot(&"upgrade")
	else:
		SoundManager.play_global_oneshot(&"ui_fail")
		unlock_failed.emit(research_node)

#region APPLYING RESEARCH

## Applies all unlocked research nodes to the given node
func apply_all_research(node: Node2D) -> void:
	var unlocked_nodes: Array[ResearchNode] = get_unlocked_nodes()
	
	for research_node: ResearchNode in unlocked_nodes:
		research_node.apply_research(node)

## Applies the given research node to the given node
func apply_research(node: Node2D, research_node: ResearchNode) -> void:
	research_node.apply_research(node)

## Applies the all unlocked research nodes to every tree in the tree_map
func apply_all_research_to_trees() -> void:
	var trees: Dictionary[Vector2i, Node2D] = TreeManager.get_tree_map()
	
	# Remove duplicates (from multitile trees)
	var trees_unique: Dictionary[Node2D, bool] = {}
	for tree: Node2D in trees.values():
		trees_unique[tree] = true
	
	# Apply upgrades to all trees
	for tree: Node2D in trees_unique.keys():
		apply_all_research(tree)

## Applies the given research node to every tree in the tree_map
func apply_research_to_trees(research_node: ResearchNode) -> void:
	var trees: Dictionary[Vector2i, Node2D] = TreeManager.get_tree_map()
	
	# Remove duplicates (from multitile trees)
	var trees_unique: Dictionary[Node2D, bool] = {}
	for tree: Node2D in trees.values():
		trees_unique[tree] = true
	
	for tree: Node2D in trees_unique.keys():
		apply_research(tree, research_node)

#endregion

#region Node Modifiers/Getters

## Updates the nodes which are unlockable based on the currently unlocked nodes
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

## Returns an array of all the research nodes
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

## Returns an array of unlocked research nodes
func get_unlocked_nodes() -> Array[ResearchNode]:
	var unlocked_nodes: Array[ResearchNode]
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node.is_unlocked():
			unlocked_nodes.append(research_node)
	
	return unlocked_nodes

## Sets which nodes are unlocked based on the given array of ids
## reset_all_nodes is optional parameter to forcefully reset all the nodes before setting them
func set_unlocked_nodes(unlocked_node_ids: Array, reset_all_nodes: bool = true) -> void:
	if reset_all_nodes:
		reset_unlocked_nodes()
	
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node.research_resource.id in unlocked_node_ids:
			research_node.unlock_research_node()
	
	update_unlockable_nodes()

## Sets all nodes to locked except for the root node
func reset_unlocked_nodes() -> void:
	var research_nodes: Array[ResearchNode] = get_research_nodes()
	
	for research_node: ResearchNode in research_nodes:
		if research_node == root_node:
			research_node.unlock_research_node()
		else:
			research_node.lock_research_node()
	
	update_unlockable_nodes()

## Get the ids of the unlocked nodes
func get_unlocked_node_ids() -> Array:
	var unlocked_nodes: Array[ResearchNode] = get_unlocked_nodes()
	var unlocked_ids: Array = unlocked_nodes.map(
		func(node: ResearchNode):
			return node.research_resource.id
	)
	return unlocked_ids

func get_root_node() -> ResearchNode:
	return root_node

#endregion

#region Tech Points

static var point_notification: Notification

func add_tech_points(amount: int) -> void:
	num_tech_points += amount
	
	if amount != 0:
		if not point_notification or point_notification.is_removed:
			point_notification = Notification.new(&"tech_point_earn", '[color=6be1e3]' + get_correct_plural_for_notif(amount), { "priority": 3, "time_remaining": 3.0, "amount": amount });
			NotificationLog.instance.add_notification(point_notification)
		else:
			var new_amount = amount + point_notification.properties.get("amount", 0)
			point_notification.set_message('[color=6be1e3]' + get_correct_plural_for_notif(new_amount))

func get_correct_plural_for_notif(total: int) -> String:
	if total == 1:
		return tr(&"NOTIF_TECH_POINT").format({ "num": total })
	else:
		return tr(&"NOTIF_TECH_POINTS").format({ "num": total })

func set_tech_points(amount: int) -> void:
	num_tech_points = amount

func get_num_tech_points() -> int:
	return num_tech_points

#endregion
