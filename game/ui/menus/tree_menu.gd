extends Control

func _on_default_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.DEFAULT_TREE

func _on_explorer_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.DEFAULT_TREE

func _on_shady_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.DEFAULT_TREE

func _on_tall_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.DEFAULT_TREE

func _on_water_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.WATER_TREE

func _on_protector_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.DEFAULT_TREE

func _on_gun_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = TreeManager.TreeType.GUN_TREE
