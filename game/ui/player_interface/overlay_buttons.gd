extends VBoxContainer



func _on_water_overlay_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	show_overlay(OverlayManager.OverlayType.WATER_OVERLAY)

func _on_health_overlay_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	show_overlay(OverlayManager.OverlayType.HEALTH_OVERLAY)




func show_overlay(overlay_type: OverlayManager.OverlayType):
	var overlay_manager = OverlayManager.instance
	
	var overlay: Overlay = overlay_manager.overlays[overlay_type]
	
	if (overlay == overlay_manager.current_overlay):
		overlay_manager.hide_overlay()
	else:
		overlay_manager.show_overlay(overlay_type)
