class_name PauseMenu
extends PanelContainer

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

func _ready() -> void:
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
	load_button.focus_entered.connect(_on_disabled_button_focus)
	main_menu_button.focus_entered.connect(_on_enabled_button_focus)
	quit_game_button.focus_entered.connect(_on_enabled_button_focus)

## Pauses if unpaused, unpauses if paused
func toggle_pause() -> void:
	if is_paused:
		unpause_game()
		SfxManager.play_sound_effect("ui_click")
	else:
		pause_game()

## Pauses the game
func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	game_paused.emit()
	
	var filter := AudioEffectLowPassFilter.new()
	filter.cutoff_hz = 800.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), filter, 0)
	
	show()
	resume_button.grab_focus() ## TEMP: So controller can navigate the menu...

func unpause_game() -> void:
	is_paused = false
	get_tree().paused = false
	game_resumed.emit()
	
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	
	hide()

#region BUTTON HANDLERS

func _on_resume_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	unpause_game()

func _on_settings_button_pressed() -> void:
	settings_button_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	## TODO: Go to the settings menu

func _on_save_button_pressed() -> void:
	save_button_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	## TODO: Open a save games screen to prompt for save

func _on_load_button_pressed() -> void:
	load_button_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	## TODO: Open a save games screen to prompt for selection

func _on_main_menu_button_pressed() -> void:
	main_menu_button_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	## TODO: Check for save game... confirmation!
	SceneLoader.transition_to_main_menu()

func _on_quit_game_button_pressed() -> void:
	quit_to_desktop_pressed.emit()
	
	SfxManager.play_sound_effect("ui_click")
	## TODO: Check for save game... confirmation!
	get_tree().quit()

func _on_enabled_button_focus() -> void:
	SfxManager.play_sound_effect("ui_click")

func _on_disabled_button_focus() -> void:
	SfxManager.play_sound_effect("ui_fail")

#endregion
