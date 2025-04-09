class_name TreeMenu
extends Control

var tree_order = [TreeManager.TreeType.DEFAULT_TREE,
	TreeManager.TreeType.EXPLORER_TREE,
	TreeManager.TreeType.TALL_TREE,
	TreeManager.TreeType.WATER_TREE,
	TreeManager.TreeType.GUN_TREE,
	TreeManager.TreeType.TECH_TREE]

@onready var node_order = $TreeCards.get_children()

var currently_selected_tree = 0

static var instance: TreeMenu

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	currently_selected_tree = tree_order.find(TreeManager.selected_tree_species)
	print(currently_selected_tree)

func next_tree() -> void:
	currently_selected_tree += 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	TreeManager.selected_tree_species = tree_order[currently_selected_tree]
	SfxManager.play_sound_effect("ui_click")
	InfoBox.get_instance().show_content_for_tree(node_order[currently_selected_tree].tree_stat)

func previous_tree() -> void:
	currently_selected_tree -= 1
	currently_selected_tree = currently_selected_tree % tree_order.size()
	TreeManager.selected_tree_species = tree_order[currently_selected_tree]
	SfxManager.play_sound_effect("ui_click")
	InfoBox.get_instance().show_content_for_tree(node_order[currently_selected_tree].tree_stat)
