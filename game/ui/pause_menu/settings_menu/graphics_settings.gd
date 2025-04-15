class_name GraphicsSettings
extends PanelContainer

@export var window_option_button: OptionButton
@export var resolution_option_button: OptionButton
@export var gui_scale_slider: Slider
@export var brightness_slider: Slider
@export var shake_slider: Slider

func _ready() -> void:
	## Initalize...
	load_graphics_settings()

func save_graphics_settings() -> void:
	Settings.set_setting("gui_scale", gui_scale_slider.value)
	Settings.set_setting("window_option", window_option_button.selected)
	Settings.save_to_config()

func load_graphics_settings() -> void:
	gui_scale_slider.value = Settings.get_setting_or_default("gui_scale", 1.0)
	window_option_button.selected = Settings.get_setting_or_default("window_option", 0)

func _on_window_option_button_item_selected(index: int) -> void:
	SfxManager.play_sound_effect("ui_click")
	
	if index == 0:
		## WINDOWED
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		## MAXIMIZED
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	elif index == 2:
		## FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	save_graphics_settings()
