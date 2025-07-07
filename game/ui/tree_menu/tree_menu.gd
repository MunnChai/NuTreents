class_name TreeMenu
extends Control

## TREE MENU
## The "hotbar" menu of trees at the bottom of the screen
## ---

## TODO:
## - Select using num keys in 1234567890 order
## - Remove/load cards from the selection options
## - Different tabs

const TREE_CARD = preload("res://ui/tree_menu/tree_card/tree_card.tscn")

@onready var tree_card_container = %TreeCardContainer

var starting_min_size = custom_minimum_size

## Tree types of cards, in the order that they are placed on the bar
var tree_order = [Global.TreeType.DEFAULT_TREE,
	Global.TreeType.EXPLORER_TREE,
	Global.TreeType.TALL_TREE,
	Global.TreeType.WATER_TREE,
	Global.TreeType.GUN_TREE,
	Global.TreeType.TECH_TREE,
	Global.TreeType.SLOWING_TREE,
	Global.TreeType.MORTAR_TREE,
	Global.TreeType.SPIKY_TREE,
	Global.TreeType.ICY_TREE,
	Global.TreeType.FIRE_TREE,
	Global.TreeType.SPRINKLER_TREE,
	]
## Index of the currently selected tree
var currently_selected_tree = 0
var is_selecting_tree := true ## Am I selecting a tree, or are we not selecting anything?

static var instance: TreeMenu # Psuedo-singleton reference

func _ready() -> void:
	instance = self

func get_currently_selected_tree_type() -> Global.TreeType:
	return tree_order[currently_selected_tree]

func set_currently_selected_tree_type(tree_type: Global.TreeType) -> void:
	currently_selected_tree = tree_order.find(tree_type)

func get_unlocked_tree_types() -> Array[Global.TreeType]:
	var tree_types: Array[Global.TreeType]
	
	for tree_card: TreeCard in tree_card_container.get_children():
		tree_types.append(tree_card.tree_type)
	
	return tree_types

func next_tree() -> void:
	currently_selected_tree += 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	SoundManager.play_global_oneshot(&"ui_click")
	#InfoBox.get_instance().show_content_for_tree(node_order[currently_selected_tree].tree_stat)

func previous_tree() -> void:
	currently_selected_tree -= 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	SoundManager.play_global_oneshot(&"ui_click")
	#InfoBox.get_instance().show_content_for_tree(node_order[currently_selected_tree].tree_stat)


func add_tree_card(tree_type: Global.TreeType):
	# DONT DO DUPLICATE CARDS
	for tree_card: TreeCard in tree_card_container.get_children():
		if tree_card.tree_type == tree_type:
			return
	
	AlmanacInfo.add_tree(tree_type)
	var new_card = TREE_CARD.instantiate()
	new_card.tree_type = tree_type
	
	tree_card_container.add_child(new_card)
	
	var notification = Notification.new(&"unlock", '[color=e09420]' + tr(&"NOTIF_UNLOCK").format({ "tree_name": TreeRegistry.get_twee_stat(tree_type).name.to_upper() }), { "priority": 3, "time_remaining": 3.0 });
	NotificationLog.instance.add_notification(notification)

func remove_all_tree_cards() -> void:
	for tree_card: TreeCard in tree_card_container.get_children():
		tree_card.queue_free()
