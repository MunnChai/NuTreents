extends Node

# For fading
const BLACK_SCREEN = preload("res://scene_loader/black_screen.tscn")

# For loading scenes
const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn") # Main menu
const MAIN = preload("res://main.tscn") # Game scene

# Fade in + out duration
const FADE_DURATION = 2.0

var black_screen: ColorRect

func _ready():
	black_screen = BLACK_SCREEN.instantiate()
	black_screen.z_index = 10
	add_child(black_screen)
	print(black_screen)

func transition_to_main_menu():
	transition_to_packed(MAIN_MENU)

func transition_to_game():
	transition_to_packed(MAIN)

func transition_to_packed(scene: PackedScene):
	var tween_in = get_tree().create_tween()
	
	tween_in.tween_property(black_screen, "modulate:a", 1.0, FADE_DURATION / 2)
	
	tween_in.finished.connect(
		func():
			get_tree().change_scene_to_packed(scene)
			
			var tween_out = get_tree().create_tween()
			
			tween_out.tween_property(black_screen, "modulate:a", 0.0, FADE_DURATION / 2)
	)
