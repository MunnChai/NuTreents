class_name Menu
extends Control

@export var tree_menu: Control
@export var tech_menu: Control
@export var settings_menu: Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var trees: TextureButton = $MenuButtons/Trees
@onready var technology: TextureButton = $MenuButtons/Technology

var is_open: bool = false

func _ready() -> void:
	animation_player.play("RESET")
	set_visibility(true, false, false)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if !is_open:
			trees.pressed.emit()
			tree_menu.focus_mode = Control.FOCUS_ALL
		else:
			close_menu()

func _on_trees_pressed() -> void:
	_update_animation_player()
	set_visibility(true, false, false)
	SfxManager.play_sound_effect("ui_pages")

func _on_technology_pressed() -> void:
	_update_animation_player()
	set_visibility(false, true, false)
	SfxManager.play_sound_effect("ui_pages")

func _on_settings_pressed() -> void:
	_update_animation_player()
	set_visibility(false, false, true)
	SfxManager.play_sound_effect("ui_pages")

func _on_close_menu_pressed() -> void:
	if is_open:
		
		is_open = false
		print("NA")
		animation_player.play_backwards("menu_appear")
		SfxManager.play_sound_effect("ui_pages")
	else:
		is_open = true
		print("YA")
		animation_player.play("menu_appear")
		SfxManager.play_sound_effect("ui_pages")

func close_menu():
	is_open = false
	animation_player.play_backwards("menu_appear")
	SfxManager.play_sound_effect("ui_pages")

func set_visibility(tree : bool, tech : bool, settings : bool):
	tree_menu.visible = tree
	tech_menu.visible = tech
	#settings_menu.visible = settings

func _update_animation_player():
	if !is_open:
		is_open = true
		animation_player.play("menu_appear")
