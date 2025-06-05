extends PanelContainer

@onready var button: Button = $Button
@onready var world_name_label: RichTextLabel = %WorldNameLabel
@onready var day_label: RichTextLabel = %DayLabel
@onready var seed_label: RichTextLabel = %SeedLabel
@onready var delete_button: Button = %DeleteButton

var has_save_file: bool = false
var save_num: int

func _ready() -> void:
	delete_button.pressed.connect(_on_delete_pressed)

func set_button_info(save_num: int, session_data: Dictionary): 
	self.save_num = save_num
	button.disabled = false
	delete_button.disabled = false
	
	# Disconnect all callables
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection["callable"])
	
	if session_data.is_empty():
		set_button_info_empty(save_num)
		return
	
	delete_button.visible = true
	has_save_file = true
	
	world_name_label.text = session_data["world_name"]
	seed_label.text = "Seed: " + str(session_data["seed"])
	day_label.text = "Day " + str(session_data["current_day"])
	
	button.pressed.connect(load_game.bind(save_num, session_data))
	
	if save_num == Global.session_id:
		button.disabled = true
		delete_button.disabled = true

func set_button_info_empty(save_num: int):
	delete_button.visible = false
	has_save_file = false
	
	world_name_label.text = "New World\n[color=ffffff](Click to create!)"
	day_label.text = ""
	seed_label.text = ""
	
	button.pressed.connect(_open_new_world_menu)

func _open_new_world_menu() -> void:
	if Global.game_state == Global.GameState.PLAYING:
		await _prompt_for_loading_world()
	
	if not ScreenUI.new_world_menu.is_open:
		ScreenUI.get_active_menu().close(ScreenUI.new_world_menu)
		ScreenUI.add_menu(ScreenUI.new_world_menu)
		ScreenUI.new_world_menu.current_session_id = save_num

func load_game(save_num: int, session_data: Dictionary) -> void:
	Global.session_id = save_num
	SfxManager.play_sound_effect("ui_click")
	if Global.game_state == Global.GameState.PLAYING:
		await _prompt_for_loading_world()
	SceneLoader.transition_to_game(session_data)

func _on_delete_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	prompt_for_deletion()

func prompt_for_deletion() -> void:
	ScreenUI.add_menu(ScreenUI.confirmation_menu)
	ScreenUI.confirmation_menu.set_message("Are you sure you want to delete world \"" + world_name_label.text + "\"?\n[color=red](This action is permanent!)")
	ScreenUI.confirmation_menu.set_accept_text("Delete \"" + world_name_label.text + "\"")
	ScreenUI.confirmation_menu.set_decline_text("Cancel")
	ScreenUI.confirmation_menu.connect_choice_to(_on_deletion_choice)
	await ScreenUI.confirmation_menu.choice_made

func _on_deletion_choice(choice: bool) -> void:
	if choice:
		delete_world()

func _prompt_for_loading_world() -> void:
	ScreenUI.add_menu(ScreenUI.confirmation_menu)
	ScreenUI.confirmation_menu.set_message("Would you like to save any unsaved progress?")
	ScreenUI.confirmation_menu.set_accept_text("Save")
	ScreenUI.confirmation_menu.set_decline_text("Load Without Saving")
	ScreenUI.confirmation_menu.connect_choice_to(_on_save_and_quit_choice)
	await ScreenUI.confirmation_menu.choice_made

func _on_save_and_quit_choice(choice: bool):
	if choice:
		SessionData.save_session_data(Global.session_id)

func delete_world() -> void:
	SessionData.clear_session_data(save_num)
	
	# Disconnect button signals
	for connection in button.pressed.get_connections():
		button.pressed.disconnect(connection["callable"])
	
	# Initialize button as a new button
	set_button_info(save_num, {})
	
	ScreenUI.load_menu.refresh()
