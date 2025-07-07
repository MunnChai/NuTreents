class_name GraphicsSettings
extends PanelContainer

## BUG: GUI Scale causes issues with a lot of parts of the game...
## - After switching, camera may be weird (not updated) until unpaused
## - Camera movement via controller is bugged because limits change
## - Main menu has bad anchors/offsetting

@export var window_option_button: OptionButton
@export var resolution_option_button: OptionButton
@export var gui_scale_slider: Slider
@export var brightness_slider: Slider
@export var shake_slider: Slider

var init = true

func _ready() -> void:
	## Initalize...
	load_graphics_settings()
	init = false

func save_graphics_settings() -> void:
	Settings.set_setting("gui_scale", gui_scale_slider.value)
	Settings.set_setting("window_option", window_option_button.selected)
	Settings.save_to_config()

func load_graphics_settings() -> void:
	#gui_scale_slider.value = Settings.get_setting_or_default("gui_scale", 1.0)
	gui_scale_slider.value = 1.0
	window_option_button.selected = Settings.get_setting_or_default("window_option", 0)
	
	get_tree().root.content_scale_factor = gui_scale_slider.value
	
	await get_tree().process_frame # For some reason, there's a bug if you call it on the first frame...
	set_window_mode(window_option_button.selected) # Set the saved window setting!

func set_window_mode(index: int) -> void:
	if index == 0:
		## WINDOWED
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		## MAXIMIZED
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	elif index == 2:
		## FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_window_option_button_item_selected(index: int) -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	
	set_window_mode(index)
	
	save_graphics_settings()


func _on_gui_scale_slider_drag_ended(value_changed: bool) -> void:
	get_tree().root.content_scale_factor = gui_scale_slider.value
	save_graphics_settings()

func _on_gui_scale_slider_value_changed(value: float) -> void:
	if !init:
		SoundManager.play_global_oneshot(&"ui_click")
