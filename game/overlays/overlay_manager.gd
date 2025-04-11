class_name OverlayManager
extends Node2D

enum OverlayType {
	WATER_OVERLAY,
	HEALTH_OVERLAY,
}

@onready var screen_darken = $ScreenDarkenCanvas

var overlays: Dictionary[OverlayType, Overlay]
var current_overlay: Overlay


# Add new overlays here
func _ready() -> void:
	overlays[OverlayType.WATER_OVERLAY] = $WorldCanvas/WaterOverlay



func show_overlay(overlay_type: OverlayType):
	var overlay: Overlay = overlays[overlay_type]
	
	if (current_overlay == overlay):
		return
	
	Global.structure_map.set_tree_transparency(0.35)
	
	if (current_overlay):
		current_overlay.hide_overlay()
	overlay.show_overlay()
	
	current_overlay = overlay
	
	screen_darken.visible = true

func hide_overlay():
	if (!current_overlay):
		return
	
	Global.structure_map.set_tree_transparency(1)
	
	current_overlay.hide_overlay()
	current_overlay = null
	
	screen_darken.visible = false
