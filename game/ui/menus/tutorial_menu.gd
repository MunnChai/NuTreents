extends Menu

@onready var tutorial_ui = $"../TutorialUI"

func _on_trees_pressed() -> void:
	if (tutorial_ui.current_animation != tutorial_ui.TREE_MENU_ANIMATION - 1):
		SfxManager.play_sound_effect("ui_fail")
		return
	
	_update_animation_player()
	set_visibility(true, false, false)
	SoundManager.play_global_oneshot(&"ui_pages")

func _on_technology_pressed() -> void:
	SfxManager.play_sound_effect("ui_fail")

func _on_settings_pressed() -> void:
	SfxManager.play_sound_effect("ui_fail")

func _on_close_menu_pressed() -> void:
	SfxManager.play_sound_effect("ui_fail")
