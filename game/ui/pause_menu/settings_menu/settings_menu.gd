class_name SettingsMenu
extends Control

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

var section := SectionType.SYSTEM

func _ready() -> void:
	pass

func switch_to(section_type: SectionType) -> void:
	section = section_type
	
	SfxManager.play_sound_effect("ui_pages")
	
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
