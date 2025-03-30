class_name PauseButton
extends Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	
	get_tree().paused = not get_tree().paused
	
	if get_tree().paused:
		text = "Unpause Game"
	else:
		text = "Pause Game"
