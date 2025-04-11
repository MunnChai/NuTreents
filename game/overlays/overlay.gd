class_name Overlay
extends Node2D

# 
# Base class for overlays
# 


func _process(delta: float) -> void:
	if (visible):
		update_highlights()



func update_highlights() -> void:
	pass



func show_overlay() -> void:
	visible = true
	
	update_highlights()

func hide_overlay() -> void:
	visible = false
