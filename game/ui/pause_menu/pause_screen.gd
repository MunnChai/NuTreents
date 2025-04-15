class_name PauseScreen
extends Control

## BUGS
## BUG: Fade in black screen is on a higher layer than the pause screen
## BUG: Pause menu shadow is hidden behind tree menu
## BUG: All time tween animations using scaled delta time (aka when fast forward, 2x as fast)
## to fix this, somehow make tweens use TimeUtil.unscaled_delta(delta)

var can_pause := true

@onready var pause_menu: PauseMenu = %PauseMenu
@onready var pause_menu_offset = %PauseMenuOffset
@onready var dimmer: ColorRect = %Dimmer

@onready var dimmer_opacity := dimmer.modulate.a

@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var settings_menu_offset: Control = %SettingsMenuOffset

func _ready() -> void:
	pause_menu.game_paused.connect(_on_game_paused)
	pause_menu.game_resumed.connect(_on_game_resumed)
	pause_menu.unpause_game()
	
	pause_menu.settings_button_pressed.connect(_on_settings_button_pressed)

func _on_settings_button_pressed() -> void:
	if settings_menu.is_open:
		close_settings_menu()
	else:
		open_settings_menu()

func open_settings_menu() -> void:
	settings_menu.open()
	
	settings_menu_offset.position = Vector2.DOWN * 50.0
	create_tween().tween_property(settings_menu_offset, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	settings_menu_offset.modulate.a = 0
	create_tween().tween_property(settings_menu_offset, "modulate", Color(pause_menu_offset.modulate, 1), 0.1)
	
	create_tween().tween_property(pause_menu_offset, "position", Vector2.LEFT * 200.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func close_settings_menu() -> void:
	settings_menu.close()
	pause_menu.settings_button.grab_focus()
	create_tween().tween_property(pause_menu_offset, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

func _process(delta: float) -> void:
	if can_pause:
		if Input.is_action_just_pressed("pause"):
			if not settings_menu.is_open:
				pause_menu.toggle_pause()
			else:
				close_settings_menu()
				SfxManager.play_sound_effect("ui_click")

func _on_game_paused() -> void:
	show()
	
	pause_menu_offset.position = Vector2.DOWN * 50.0
	create_tween().tween_property(pause_menu_offset, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	pause_menu_offset.modulate.a = 0
	create_tween().tween_property(pause_menu_offset, "modulate", Color(pause_menu_offset.modulate, 1), 0.1)
	
	dimmer.modulate.a = 0
	create_tween().tween_property(dimmer, "modulate", Color(dimmer.modulate, dimmer_opacity), 0.1)

func _on_game_resumed() -> void:
	hide()
	settings_menu.close()
	
	## TODO: Reverse the opening animation upon closing... but terminate if re-opened immediately afterward!
