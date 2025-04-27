extends PanelContainer

var is_open := false

@onready var world_name: LineEdit = $MarginContainer/VBoxContainer/VBoxContainer/WorldName
@onready var create_button: Button = %CreateButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	create_button.pressed.connect(create_new_world)
	
	world_name.text_changed.connect(check_valid_world_name)

func open():
	is_open = true
	show()

func close():
	is_open = false
	hide()

func check_valid_world_name():
	# Ensure naem
	if world_name.text.length() == 0:
		create_button.disabled = true
	else:
		create_button.disabled = false

func create_new_world() -> void:
	# Disable line edit
	world_name.editable = false
	
	# Generate a random seed
	Global.new_seed()
	
	# Create new save
	SessionData.create_new_session_data(Global.session_id, world_name.text, Global.get_seed())
	
	SceneLoader.transition_to_game()
