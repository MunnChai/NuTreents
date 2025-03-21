extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_default_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 1

func _on_explorer_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 2


func _on_shady_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 3


func _on_tall_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 4


func _on_water_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 5


func _on_protector_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 6


func _on_gun_tree_btn_pressed() -> void:
	TreeManager.selected_tree_species = 7
