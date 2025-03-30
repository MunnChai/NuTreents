extends Control

@onready var animation_player = $AnimationPlayer
var animation_library: AnimationLibrary

var current_animation: int = 0

func _ready() -> void:
	animation_library = animation_player.get_animation_library("tutorial_animation")
	play_next_animation()

func skip_tutorial() -> void:
	SceneLoader.transition_to_game()


func _on_continue_button_pressed():
	play_next_animation()
	

# Plays the next animation in the list
func play_next_animation() -> void:
	current_animation += 1
	play_animation(current_animation)

func play_animation(index: int) -> void:
	animation_player.play(get_animation_name(index))

func get_animation_name(index: int) -> StringName:
	var list = animation_library.get_animation_list()
	
	if (index >= list.size()):
		print("WARNING: index of animation out of bounds: ", index, ". Clamping to: ", list.size() - 1)
		index = list.size() - 1
	
	return list[current_animation]
