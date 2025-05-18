class_name NewWorldMenu
extends ScreenMenu

var is_open := false

@onready var world_name: LineEdit = %WorldName
@onready var create_button: Button = %CreateButton
@onready var back_button: Button = %BackButton

@onready var world_size_buttons: HBoxContainer = %WorldSizeButtons
@onready var difficulty_buttons: HBoxContainer = %DifficultyButtons

@onready var center_tree_animation: AnimationPlayer = %CenterTreeAnimation
@onready var front_left_tree_animation: AnimationPlayer = %FrontLeftTreeAnimation
@onready var front_right_tree_animation: AnimationPlayer = %FrontRightTreeAnimation



const DEFAULT_WORLD_SIZE: WorldSettings.WorldSize = WorldSettings.WorldSize.MEDIUM
var current_world_size: WorldSettings.WorldSize = DEFAULT_WORLD_SIZE

func _ready() -> void:
	create_button.pressed.connect(create_new_world)
	back_button.pressed.connect(_back)
	world_name.focus_entered.connect(func(): 
		SfxManager.play_sound_effect("ui_click"))
	world_name.text_changed.connect(check_valid_world_name)
	
	_connect_button_signals()
	_connect_animation_signals()
	
	select_world_size(DEFAULT_WORLD_SIZE)

func _connect_button_signals():
	
	var index = 1 # Small = 1, Medium = 2, Large = 3
	for button: Button in world_size_buttons.get_children():
		button.pressed.connect(_on_world_size_button_pressed.bind(index))
		index += 1

func _on_world_size_button_pressed(world_size: WorldSettings.WorldSize):
	select_world_size(world_size)
	SfxManager.play_sound_effect("ui_click")

func select_world_size(world_size: WorldSettings.WorldSize):
	var i = 1
	for button: Button in world_size_buttons.get_children():
		button.button_pressed = (i == world_size)
		i += 1
	
	current_world_size = world_size
	
	# Munn: A bunch of animation stuff, not really necessary
	if world_size == WorldSettings.WorldSize.SMALL:
		transition_tree_state(center_tree_animation, TreeAnimationState.SMALL)
		transition_tree_state(front_left_tree_animation, TreeAnimationState.HIDDEN)
		transition_tree_state(front_right_tree_animation, TreeAnimationState.HIDDEN)
	elif world_size == WorldSettings.WorldSize.MEDIUM:
		transition_tree_state(center_tree_animation, TreeAnimationState.LARGE)
		transition_tree_state(front_left_tree_animation, TreeAnimationState.SMALL)
		transition_tree_state(front_right_tree_animation, TreeAnimationState.SMALL)
	elif world_size == WorldSettings.WorldSize.LARGE:
		transition_tree_state(center_tree_animation, TreeAnimationState.LARGE)
		transition_tree_state(front_left_tree_animation, TreeAnimationState.LARGE)
		transition_tree_state(front_right_tree_animation, TreeAnimationState.LARGE)

func reset_inputs() -> void:
	world_name.editable = true
	world_name.text = "New Forest"

func _back() -> void:
	Global.session_id = 0
	ScreenUI.exit_menu()


func _connect_animation_signals():
	var animations = [center_tree_animation, front_left_tree_animation, front_right_tree_animation]
	
	for animation: AnimationPlayer in animations:
		animation.animation_finished.connect(_on_animation_finished.bind(animation))

## Visual Panel Animations
enum TreeAnimationState {
	HIDDEN = 0,
	SMALL = 1,
	LARGE = 2,
}

func transition_tree_state(animation_player: AnimationPlayer, next_state: TreeAnimationState):
	if animation_player.current_animation == "":
		animation_player.play("hidden")
	
	if animation_player.current_animation == "hidden":
		if next_state == TreeAnimationState.SMALL:
			animation_player.speed_scale = 1
			animation_player.play("grow_small")
			animation_player.queue("small")
		elif next_state == TreeAnimationState.LARGE:
			animation_player.speed_scale = 1
			animation_player.play("grow_small")
			animation_player.queue("grow_large")
	
	elif animation_player.current_animation == "small":
		if next_state == TreeAnimationState.HIDDEN:
			animation_player.speed_scale = -1
			animation_player.play("grow_small", -1, 1, true)
		elif next_state == TreeAnimationState.LARGE:
			animation_player.speed_scale = 1
			animation_player.play("grow_large")
		
	elif animation_player.current_animation == "large":
		if next_state == TreeAnimationState.HIDDEN:
			animation_player.speed_scale = -1
			animation_player.play("grow_small", -1, 1, true)
		elif next_state == TreeAnimationState.SMALL:
			animation_player.speed_scale = -1
			animation_player.play("grow_large", -1, 1, true)

func _on_animation_finished(animation_name: String, animation_player: AnimationPlayer):
	
	if animation_name == "grow_small" and animation_player.speed_scale > 0:
		animation_player.play("small")
	elif animation_name == "grow_small" and animation_player.speed_scale < 0:
		animation_player.play("hidden")
	
	if animation_name == "grow_large" and animation_player.speed_scale > 0:
		animation_player.play("large")
	elif animation_name == "grow_large" and animation_player.speed_scale < 0:
		animation_player.play("small")



## SCREEN UI IMPLEMENTATIONS

@onready var start_position := position

func open(previous_menu: ScreenMenu) -> void:
	is_open = true
	show()
	reset_inputs()
	
	position += Vector2.DOWN * 50.0
	TweenUtil.whoosh(self, start_position, 0.4)
	TweenUtil.fade(self, 1, 0.2)
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	
	SfxManager.play_sound_effect("ui_click")

func close(next_menu: ScreenMenu) -> void:
	is_open = false
	
	TweenUtil.whoosh(self, start_position + Vector2.DOWN * 50.0, 0.4)
	TweenUtil.fade(self, 0, 0.1).finished.connect(_finish_close)
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
func _finish_close() -> void:
	hide()

func return_to(previous_menu: ScreenMenu) -> void:
	pass





func check_valid_world_name():
	# Ensure naem
	if world_name.text.length() == 0:
		create_button.disabled = true
	else:
		create_button.disabled = false

func create_new_world() -> void:
	
	SfxManager.play_sound_effect("ui_pages")
	
	# Disable button to prevent repeated presses
	create_button.disabled = true
	
	# Generate a random seed
	Global.new_seed()
	
	var metadata := {
		"session_id": Global.session_id,
		"world_name": world_name.text.strip_edges(),
		"seed": Global.get_seed(),
		"world_size": current_world_size
	}
	
	# Create new save
	SessionData.create_new_session_data(metadata)
	
	SceneLoader.transition_to_tutorial()
