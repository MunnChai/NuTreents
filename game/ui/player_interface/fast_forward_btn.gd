extends TextureButton

func _ready() -> void:
	Engine.time_scale = 1

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 2
	else:
		Engine.time_scale = 1
	SfxManager.play_sound_effect("ui_click")

#func _gui_input(event: InputEvent) -> void:
	#get_viewport().set_input_as_handled()
