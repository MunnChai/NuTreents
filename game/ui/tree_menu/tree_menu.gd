class_name TreeMenu
extends Control

## TREE MENU
## The "hotbar" menu of trees at the bottom of the screen
## ---

const TREE_CARD = preload("res://ui/tree_menu/tree_card/tree_card.tscn")

@onready var tree_card_container = %TreeCardContainer

## NEW: Emitted whenever the currently selected tree changes.
## This allows other nodes, like the cursor, to react to selection changes.
signal selection_changed

var starting_min_size = custom_minimum_size

var tree_order = [
	Global.TreeType.DEFAULT_TREE,
	Global.TreeType.WATER_TREE,
	Global.TreeType.GUN_TREE,
	Global.TreeType.SLOWING_TREE,
	Global.TreeType.FIRE_TREE,
	Global.TreeType.MORTAR_TREE,
	Global.TreeType.TALL_TREE,
	Global.TreeType.SPIKY_TREE,
	Global.TreeType.ICY_TREE,
	Global.TreeType.EXPLORER_TREE,
	Global.TreeType.SPRINKLER_TREE,
	Global.TreeType.TECH_TREE,
]

var currently_selected_tree = -1
var is_selecting_tree := true

static var instance: TreeMenu

func _ready() -> void:
	instance = self
	
	DebugConsole.register("unlock_all_trees", func(args: PackedStringArray):
		for type: Global.TreeType in tree_order:
			add_tree_card(type)
		, "Unlocks every tree type")

func get_currently_selected_tree_type() -> Global.TreeType:
	if currently_selected_tree == -1:
		return -1 # Return an invalid type if nothing is selected
	return tree_order[currently_selected_tree]

func set_currently_selected_tree_type(tree_type: Global.TreeType) -> void:
	if currently_selected_tree == tree_order.find(tree_type):
		currently_selected_tree = -1
		IsometricCursor.instance.return_to_default_state()
		selection_changed.emit() # Emit signal on deselect
		return
	
	if not tree_type in get_unlocked_tree_types():
		return
	
	currently_selected_tree = tree_order.find(tree_type)
	IsometricCursor.instance.enter_state(IsometricCursor.CursorState.PLANT)
	selection_changed.emit() # Emit signal on new selection

func deselect_currently_selected_tree_type() -> void:
	currently_selected_tree = -1
	selection_changed.emit()

func get_unlocked_tree_types() -> Array[Global.TreeType]:
	var tree_types: Array[Global.TreeType]
	
	for tree_card: TreeCard in tree_card_container.get_children():
		tree_types.append(tree_card.tree_type)
	
	return tree_types

func get_tree_type_at(index: int) -> Global.TreeType:
	var tree_cards: Array = tree_card_container.get_children()
	if index >= tree_cards.size():
		return -1
	
	var tree_card: TreeCard = tree_cards[index]
	return tree_card.tree_type

func next_tree() -> void:
	currently_selected_tree += 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	SoundManager.play_global_oneshot(&"ui_click")
	selection_changed.emit() # Emit signal on change

func previous_tree() -> void:
	currently_selected_tree -= 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	SoundManager.play_global_oneshot(&"ui_click")
	selection_changed.emit() # Emit signal on change

func add_tree_card(tree_type: Global.TreeType):
	for tree_card: TreeCard in tree_card_container.get_children():
		if tree_card.tree_type == tree_type:
			return
	
	AlmanacInfo.add_tree(tree_type)
	var new_card = TREE_CARD.instantiate()
	new_card.tree_type = tree_type
	
	tree_card_container.add_child(new_card)
	tree_card_container.move_child(new_card, tree_order.find(tree_type))
	
	var notification = Notification.new(&"unlock", '[color=e09420]' + tr(&"NOTIF_UNLOCK").format({ "tree_name": TreeRegistry.get_twee_stat(tree_type).name.to_upper() }), { "priority": 3, "time_remaining": 3.0 });
	if is_instance_valid(NotificationLog.instance):
		NotificationLog.instance.add_notification(notification)

func remove_all_tree_cards() -> void:
	for tree_card: TreeCard in tree_card_container.get_children():
		tree_card.queue_free()
