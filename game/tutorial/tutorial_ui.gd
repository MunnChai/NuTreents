extends Control

enum TutorialAnimation {
	WELCOME = 1,
	MOTHER_TREE_INTRO = 2,
	PLANT_TREE = 3,
	WATER_MANAGEMENT = 4,
	CAMERA_CONTROLS = 5,
	REMOVE_TREE = 6,
	NIGHT_WARNING = 7,
	END_TUTORIAL = 8,
}

const ANIMATION_LIBRARY_NAME: String = "tutorial_animation"

# Various references to random parts of the UI
@onready var cursor = $"../../../World/TileMaps/BuildingManager/Cursor"
@onready var input_handler = $"../../../World/InputHandler"
@onready var visual_cursor = $"../../../World/TileMaps/BuildingManager/VisualCursor"
@onready var virtual_cursor = $"../../../World/VirtualCursor"

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
	
	turn_input_off()


func connect_tutorial_signals() -> void:
	# Connect place a tree
	TreeManager.tree_placed.connect(_on_first_tree_placed)

#region SignalCallbacks
func _on_first_tree_placed(tree: Node2D):
	var tree_stat_component: TweeStatComponent = Components.get_component(tree, TweeStatComponent)
	if tree_stat_component.type == Global.TreeType.MOTHER_TREE:
		return
	
	play_next_animation()
	TreeManager.tree_placed.disconnect(_on_first_tree_placed)

func _on_continue_button_pressed():
	SfxManager.play_sound_effect("ui_click")
	
	if (current_animation == TutorialAnimation.END_TUTORIAL):
		SceneLoader.transition_to_game()
		return
	
	play_next_animation()
#endregion


#region AnimationControls

# Plays the next animation in the list
func play_next_animation() -> void:
	current_animation += 1
	play_animation(current_animation)

func play_animation(index: int) -> void:
	current_animation = index
	animation_player.play(ANIMATION_LIBRARY_NAME + "/" + str(get_animation_name(index)))
	
	# Show or hide cursor
	if (index == TutorialAnimation.PLANT_TREE || index >= TutorialAnimation.CAMERA_CONTROLS):
		turn_input_on()
	else:
		turn_input_off()

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
	
	return animation_name
#endregion


func skip_tutorial() -> void:
	SfxManager.play_sound_effect("ui_click")
	SceneLoader.transition_to_game()

#region InputControls
func turn_input_on() -> void:
	cursor.is_visible = true
	input_handler.is_enabled = true
	visual_cursor.visible = true
	visual_cursor.is_process_enabled = true
	virtual_cursor.visible = true

func turn_input_off() -> void:
	cursor.is_visible = false
	input_handler.is_enabled = false
	visual_cursor.visible = false
	visual_cursor.is_process_enabled = false
	virtual_cursor.visible = false
#endregion
