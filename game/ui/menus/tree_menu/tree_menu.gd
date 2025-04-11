class_name TreeMenu
extends Control

var tree_order = [Global.TreeType.DEFAULT_TREE,
	Global.TreeType.EXPLORER_TREE,
	Global.TreeType.TALL_TREE,
	Global.TreeType.WATER_TREE,
	Global.TreeType.GUN_TREE,
	Global.TreeType.TECH_TREE]

@onready var node_order = $TreeCards.get_children()

var currently_selected_tree = 0

static var instance: TreeMenu

func _ready() -> void:
	instance = self

func get_currently_selected_tree_type() -> Global.TreeType:
	return tree_order[currently_selected_tree]

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
