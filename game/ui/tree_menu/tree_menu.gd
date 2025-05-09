class_name TreeMenu
extends Control

## TREE MENU
## The "hotbar" menu of trees at the bottom of the screen
## ---

## TODO:
## - Select using num keys in 1234567890 order
## - Remove/load cards from the selection options
## - Different tabs

## Tree types of cards, in the order that they are placed on the bar
var tree_order = [Global.TreeType.DEFAULT_TREE,
	Global.TreeType.EXPLORER_TREE,
	Global.TreeType.TALL_TREE,
	Global.TreeType.WATER_TREE,
	Global.TreeType.GUN_TREE,
	Global.TreeType.TECH_TREE]
## Index of the currently selected tree
var currently_selected_tree = 0

static var instance: TreeMenu # Psuedo-singleton reference

func _ready() -> void:
	instance = self

func get_currently_selected_tree_type() -> Global.TreeType:
	return tree_order[currently_selected_tree]

func set_currently_selected_tree_type(tree_type: Global.TreeType) -> void:
	currently_selected_tree = tree_order.find(tree_type)

func next_tree() -> void:
	currently_selected_tree += 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	SfxManager.play_sound_effect("ui_click")
	#InfoBox.get_instance().show_content_for_tree(node_order[currently_selected_tree].tree_stat)

func previous_tree() -> void:
	currently_selected_tree -= 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	SfxManager.play_sound_effect("ui_click")
	#InfoBox.get_instance().show_content_for_tree(node_order[currently_selected_tree].tree_stat)
