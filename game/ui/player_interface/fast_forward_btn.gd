extends TextureButton

func _ready() -> void:
	Engine.time_scale = 1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fast_forward"):
		if Engine.time_scale == 1:
			#Engine.time_scale = 3
			button_pressed = true
		else:
			Engine.time_scale = 1
			button_pressed = false
		#SfxManager.play_sound_effect("ui_click")

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 3
	else:
		Engine.time_scale = 1
	SfxManager.play_sound_effect("ui_click")

#func _gui_input(event: InputEvent) -> void:
	#get_viewport().set_input_as_handled()

## TODO: Enforce tooltip hierarchy

func _on_mouse_entered() -> void:
	pass
	#if button_pressed:
		#GameCursor.instance.show_tooltip("Enable Fast Forward", 1)
	#else:
		#GameCursor.instance.show_tooltip("Disable Fast Forward", 1)

func _on_mouse_exited() -> void:
	pass
	#GameCursor.instance.hide_tooltip()
