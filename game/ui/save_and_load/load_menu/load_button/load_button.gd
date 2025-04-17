extends PanelContainer

@onready var button: Button = $Button
@onready var world_name_label: RichTextLabel = %WorldNameLabel
@onready var day_label: RichTextLabel = %DayLabel
@onready var seed_label: RichTextLabel = %SeedLabel
@onready var delete_button: Button = %DeleteButton

var has_save_file: bool = false
var save_num: int

func _ready() -> void:
	delete_button.pressed.connect(delete_world)

func set_button_info(save_num: int, session_data: Dictionary): 
	self.save_num = save_num
	
	if session_data.is_empty():
		set_button_info_empty(save_num)
		return
	
	delete_button.visible = true
	has_save_file = true
	
	world_name_label.text = session_data["world_name"]
	seed_label.text = "Seed: " + str(session_data["seed"])
	
	button.pressed.connect(load_game.bind(save_num, session_data))

func set_button_info_empty(save_num: int):
	delete_button.visible = false
	has_save_file = false
	
	world_name_label.text = "New World"
	day_label.text = ""
	seed_label.text = ""

func load_game(save_num: int, session_data: Dictionary) -> void:
	Global.session_id = save_num
	SceneLoader.transition_to_game(session_data)

func delete_world() -> void:
	SessionData.clear_session_data(save_num)
	
	# Disconnect button signals
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection["callable"])
	
	# Initialize button as a new button
	set_button_info(save_num, {})
