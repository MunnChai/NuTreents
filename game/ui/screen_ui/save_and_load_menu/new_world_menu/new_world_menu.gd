class_name NewWorldMenu
extends ScreenMenu

var is_open := false

@onready var world_name: LineEdit = %WorldName
@onready var create_button: Button = %CreateButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	create_button.pressed.connect(create_new_world)
	back_button.pressed.connect(_back)
	world_name.focus_entered.connect(func(): 
		SfxManager.play_sound_effect("ui_click"))
	world_name.text_changed.connect(check_valid_world_name)

func reset_inputs() -> void:
	world_name.editable = true
	world_name.text = "New Forest"

func _back() -> void:
	Global.session_id = 0
	ScreenUI.exit_menu()

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
	
	# Disable line edit
	world_name.editable = false
	
	# Generate a random seed
	Global.new_seed()
	
	# Create new save
	SessionData.create_new_session_data(Global.session_id, world_name.text.strip_edges(), Global.get_seed())
	
	SceneLoader.transition_to_game()
