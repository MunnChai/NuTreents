extends Control

func _on_default_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 1

func _on_explorer_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 0

func _on_shady_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 0

func _on_tall_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 0

func _on_water_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 0

func _on_protector_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 0

func _on_gun_tree_card_pressed() -> void:
	TreeManager.selected_tree_species = 0
