extends Control

const ANIMATION_LIBRARY_NAME: String = "tutorial_animation"

# Various references to random parts of the game
@onready var tree_menu_button = $"../Menu/MenuButtons/Trees"
@onready var menu = $"../Menu"
@onready var cursor = $"../../../World/TileMaps/BuildingManager/Cursor"
@onready var input_handler = $"../../../World/InputHandler"

# Animation stuff
@onready var animation_player = $AnimationPlayer
var animation_library: AnimationLibrary

var current_animation: int = 0

# Get the animation library, and also play the first animation
func _ready() -> void:
	animation_library = animation_player.get_animation_library(ANIMATION_LIBRARY_NAME)
	
	play_next_animation()
	
	# Connect 1 time signals
	connect_tutorial_signals()
	
	cursor.is_visible = false
	input_handler.is_enabled = false

# Plays the next animation in the list
func play_next_animation() -> void:
	current_animation += 1
	play_animation(current_animation)

func play_animation(index: int) -> void:
	print(ANIMATION_LIBRARY_NAME + "/" + get_animation_name(index))
	animation_player.play(ANIMATION_LIBRARY_NAME + "/" + str(get_animation_name(index)))
	print(current_animation)

func get_animation_name(index: int) -> StringName:
	var list = animation_library.get_animation_list()
	
	if (index >= list.size()):
		print("WARNING: index of animation out of bounds: ", index, ". Clamping to: ", list.size() - 1)
		index = list.size() - 1
		current_animation = index
	
	var animation_name = "hidden"
	for list_name in list:
		if (list_name.begins_with(str(index))):
			animation_name = list_name
	
	if (index == 5 || index >= 7):
		cursor.is_visible = true
		input_handler.is_enabled = true
	else:
		cursor.is_visible = false
		input_handler.is_enabled = false
	
	return animation_name



func connect_tutorial_signals() -> void:
	# Connect open tree menu
	tree_menu_button.pressed.connect(_on_tree_menu_opened)
	
	# Connect place a tree
	TreeManager.tree_placed.connect(_on_first_tree_placed)

const TREE_MENU_ANIMATION = 4
func _on_tree_menu_opened():
	if (current_animation != TREE_MENU_ANIMATION - 1):
		return
	
	current_animation = TREE_MENU_ANIMATION
	play_animation(TREE_MENU_ANIMATION) # Water management animation
	tree_menu_button.pressed.disconnect(_on_tree_menu_opened)

const WATER_MANAGEMENT_ANIMATION = 6
func _on_first_tree_placed():
	if (current_animation != WATER_MANAGEMENT_ANIMATION - 1):
		return
	
	current_animation = WATER_MANAGEMENT_ANIMATION
	play_animation(WATER_MANAGEMENT_ANIMATION) # Water management animation
	TreeManager.tree_placed.disconnect(_on_first_tree_placed)

func skip_tutorial() -> void:
	SfxManager.play_sound_effect("ui_click")
	SceneLoader.transition_to_game()

const END_TUTORIAL_INDEX = 9
func _on_continue_button_pressed():
	SfxManager.play_sound_effect("ui_click")
	
	if (current_animation == TREE_MENU_ANIMATION && menu.is_open):
		menu.close_menu()
	
	if (current_animation == END_TUTORIAL_INDEX):
		SceneLoader.transition_to_game()
		return
	
	play_next_animation()
