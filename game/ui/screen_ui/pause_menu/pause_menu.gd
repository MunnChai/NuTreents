class_name PauseMenu
extends ScreenMenu

## PAUSE MENU
## The first menu that appears in the overlay pause screen

var is_paused := false

signal game_paused
signal game_resumed
signal returned_to_pause_screen
signal settings_button_pressed
signal save_button_pressed
signal load_button_pressed
signal main_menu_button_pressed
signal quit_to_desktop_pressed

@onready var resume_button: Button = %ResumeButton
@onready var settings_button: Button = %SettingsButton
@onready var save_button: Button = %SaveButton
@onready var load_button: Button = %LoadButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var quit_game_button: Button = %QuitGameButton

@onready var starting_position := position

func open(previous_menu: ScreenMenu) -> void:
	position = starting_position
	pause_game()
	
	## ANIMATION
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)

func close(next_menu: ScreenMenu) -> void:
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)
func _finish_close() -> void:
	unpause_game()

func return_to(previous_menu: ScreenMenu) -> void:
	show()
	
	if previous_menu == ScreenUI.confirmation_menu:
		return
	
	if previous_menu == ScreenUI.settings_menu:
		## ANIMATION
		TweenUtil.pop_delta(self, Vector2(0.3, -0.3), 0.3)
		TweenUtil.whoosh(self, starting_position, 0.4)
	else:
		## ANIMATION
		TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
		position = starting_position + Vector2.DOWN * 100.0
		TweenUtil.whoosh(self, starting_position, 0.4)
		TweenUtil.fade(self, 1.0, 0.1)

func _ready() -> void:
	## TODO: Figure out how to scale for really small windows, and make sure right size...
	get_tree().root.content_scale_factor = 1.0
	setup_button_signals()

func setup_button_signals() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)
	
	resume_button.focus_entered.connect(_on_enabled_button_focus)
	settings_button.focus_entered.connect(_on_enabled_button_focus)
	save_button.focus_entered.connect(_on_disabled_button_focus)
	load_button.focus_entered.connect(_on_enabled_button_focus)
	main_menu_button.focus_entered.connect(_on_enabled_button_focus)
	quit_game_button.focus_entered.connect(_on_enabled_button_focus)

## Pauses if unpaused, unpauses if paused
func toggle_pause() -> void:
	if is_paused:
		unpause_game()
		SfxManager.play_sound_effect("ui_click")
	else:
		pause_game()

var previous_time_scale := 1.0

## Pauses the game
func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	game_paused.emit()
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = true
	
	previous_time_scale = Engine.time_scale
	Engine.time_scale = 1.0
	
	var filter := AudioEffectLowPassFilter.new()
	filter.cutoff_hz = 800.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), filter, 0)
	
	NutreentsDiscordRPC.update_details("Navigating menus")
	
	show()
	resume_button.grab_focus() ## TEMP: So controller can navigate the menu...

func unpause_game() -> void:
	Engine.time_scale = previous_time_scale
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = false
	
	is_paused = false
	get_tree().paused = false
	game_resumed.emit()
	
	NutreentsDiscordRPC.update_details("Growing a forest")
	
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	
	hide()

#region BUTTON HANDLERS

const SETTINGS_MENU = preload("res://ui/screen_ui/pause_menu/settings_menu/settings_menu.tscn")

func _on_resume_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.terminate_stack()

func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	
	if ScreenUI.settings_menu.is_open:
		ScreenUI.exit_menu()
	else:
		ScreenUI.add_menu(ScreenUI.settings_menu)
		TweenUtil.pop_delta(self, Vector2(0.3, -0.3), 0.2)
		TweenUtil.whoosh(self, position + Vector2.LEFT * 200.0, 0.25)
	
	## TODO: Go to the settings menu

func _on_save_button_pressed() -> void:
	save_button_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	## TODO: Open a save games screen to prompt for save

func _on_load_button_pressed() -> void:
	load_button_pressed.emit()
	
	if ScreenUI.get_active_menu() == ScreenUI.settings_menu:
		ScreenUI.exit_menu()
	
	SfxManager.play_sound_effect("ui_click")
	
	ScreenUI.add_menu(ScreenUI.load_menu)
	
	TweenUtil.scale_to(self, Vector2(0.9, 1.1), 0.05)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close_for_load)
	
	## TODO: Open a save games screen to prompt for selection
func _finish_close_for_load() -> void:
	hide()

func _on_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()
	SfxManager.play_sound_effect("ui_click")
	await _prompt_for_save_and_quit()
	SceneLoader.transition_to_main_menu()

func _prompt_for_save_and_quit() -> void:
	ScreenUI.add_menu(ScreenUI.confirmation_menu)
	ScreenUI.confirmation_menu.set_message("Would you like to save any unsaved progress?")
	ScreenUI.confirmation_menu.set_accept_text("Save & Quit")
	ScreenUI.confirmation_menu.set_decline_text("Quit Without Saving")
	ScreenUI.confirmation_menu.connect_choice_to(_on_save_and_quit_choice)
	await ScreenUI.confirmation_menu.choice_made

func _on_save_and_quit_choice(choice: bool) -> void:
	if choice:
		SessionData.save_session_data(Global.session_id)

func _on_quit_game_button_pressed() -> void:
	quit_to_desktop_pressed.emit()
	SfxManager.play_sound_effect("ui_click")
	await _prompt_for_save_and_quit()
	get_tree().quit()

func _on_enabled_button_focus() -> void:
	SfxManager.play_sound_effect("ui_click")

func _on_disabled_button_focus() -> void:
	SfxManager.play_sound_effect("ui_fail")

#endregion
