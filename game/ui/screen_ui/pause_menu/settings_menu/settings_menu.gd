class_name SettingsMenu
extends ScreenMenu

enum SectionType {
	SYSTEM,
	AUDIO,
	GRAPHICS,
	CONTROLS,
}

@onready var system_button: Button = %SystemButton
@onready var audio_button: Button = %AudioButton
@onready var graphics_button: Button = %GraphicsButton
@onready var controls_button: Button = %ControlsButton

@onready var system_settings: PanelContainer = %SystemSettings
@onready var audio_settings: PanelContainer = %AudioSettings
@onready var graphics_settings: PanelContainer = %GraphicsSettings
@onready var controls_settings: PanelContainer = %ControlsSettings

@onready var start_position := position

var is_open := false
var section := SectionType.SYSTEM

func _ready() -> void:
	system_button.focus_entered.connect(_on_button_focused)
	audio_button.focus_entered.connect(_on_button_focused)
	graphics_button.focus_entered.connect(_on_button_focused)
	controls_button.focus_entered.connect(_on_button_focused)
	hide()

## SCREEN UI IMPLEMENTATIONS

func open(previous_menu: ScreenMenu) -> void:
	switch_to(SectionType.SYSTEM)
	is_open = true
	system_button.grab_focus()
	show()
	
	position += Vector2.DOWN * 50.0
	TweenUtil.whoosh(self, start_position, 0.4)
	TweenUtil.fade(self, 1, 0.2)
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)

func close(next_menu: ScreenMenu) -> void:
	is_open = false
	
	TweenUtil.whoosh(self, start_position + Vector2.DOWN * 50.0, 0.4)
	TweenUtil.fade(self, 0, 0.1).finished.connect(_finish_close)
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
func _finish_close() -> void:
	hide()

func return_to(previous_menu: ScreenMenu) -> void:
	pass

func switch_to(section_type: SectionType) -> void:
	section = section_type
	
	SfxManager.play_sound_effect("ui_pages")
	
	if is_open:
		scale = Vector2(1.1, 1.1)
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	system_settings.hide()
	audio_settings.hide()
	graphics_settings.hide()
	controls_settings.hide()
	
	match section:
		SectionType.SYSTEM:
			system_settings.show()
		SectionType.AUDIO:
			audio_settings.show()
		SectionType.GRAPHICS:
			graphics_settings.show()
		SectionType.CONTROLS:
			controls_settings.show()


func _on_system_button_pressed() -> void:
	switch_to(SectionType.SYSTEM)

func _on_audio_button_pressed() -> void:
	switch_to(SectionType.AUDIO)

func _on_graphics_button_pressed() -> void:
	switch_to(SectionType.GRAPHICS)

func _on_controls_button_pressed() -> void:
	switch_to(SectionType.CONTROLS)

func _on_button_focused() -> void:
	SfxManager.play_sound_effect("ui_click")
