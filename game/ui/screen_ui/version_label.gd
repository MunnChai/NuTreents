extends RichTextLabel

func _process(delta: float) -> void:
	if ScreenUI.pause_menu.is_paused:
		show()
	else:
		hide()
