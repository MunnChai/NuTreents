extends VBoxContainer

# Audio bus indexes
var master_idx: int
var music_idx: int
var sfx_idx: int

@onready var master_slider: HSlider = $MasterContainer/MasterSlider
@onready var music_slider: HSlider = $MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $SFXContainer/SFXSlider

@export var slider_label: Label

var init = true

func _ready() -> void:
	master_idx = AudioServer.get_bus_index("Master")
	music_idx = AudioServer.get_bus_index("Music")
	sfx_idx = AudioServer.get_bus_index("SFX")
	
	# Initialize slider value to match dB from audio buses (100% -> 0 dB, 0% -> -80 dB)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_idx))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_idx))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_idx))
	slider_label.visible = false
	
	master_slider.connect("drag_ended", func(val: bool): slider_label.visible = false)
	music_slider.connect("drag_ended", func(val: bool): slider_label.visible = false)
	sfx_slider.connect("drag_ended", func(val: bool): slider_label.visible = false)

func _process(delta: float) -> void:
	if init:
		init = false

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(value))
	_update_slider_label(value, master_slider)
	if !init:
		SfxManager.play_sound_effect("ui_click")

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_idx, linear_to_db(value))
	_update_slider_label(value, music_slider)
	if !init:
		SfxManager.play_sound_effect("ui_click")

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(value))
	_update_slider_label(value, sfx_slider)
	if !init:
		SfxManager.play_sound_effect("ui_click")

func _update_slider_label(value: float, slider: HSlider) -> void:
	slider_label.text = str(int(value * 100)) + "%"
	
	var offset: float = slider_label.size.x / 2
	var min: float = slider.global_position.x - offset
	var max: float = slider.global_position.x + slider.size.x - offset
	slider_label.global_position.x = clamp(get_global_mouse_position().x - offset, min, max)
	slider_label.global_position.y = slider.global_position.y - slider_label.size.y
	slider_label.visible = true
