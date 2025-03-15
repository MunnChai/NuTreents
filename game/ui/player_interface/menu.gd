extends Control

@export var tree_menu: Control
@export var tech_menu: Control
@export var settings_menu: Control

func _ready() -> void:
	set_visibility(true, false, false)

func _on_trees_pressed() -> void:
	set_visibility(true, false, false)

func _on_technology_pressed() -> void:
	set_visibility(false, true, false)

func _on_settings_pressed() -> void:
	set_visibility(false, false, true)

func set_visibility(tree : bool, tech : bool, settings : bool):
	tree_menu.visible = tree
	tech_menu.visible = tech
	settings_menu.visible = settings
