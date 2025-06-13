class_name PopupEmitterComponent
extends Node2D

@export var popup_color: Color = Color(1, 1, 1, 1)
@export var outline_color: Color = Color(0, 0, 0, 1)

func popup_number(number: float, show_decimals: bool = false):
	var text := ""
	
	if show_decimals:
		text = str(number)
	else:
		text = str(int(number))
	
	PopupManager.create_popup(text, global_position, popup_color, outline_color)

func popup_text(text: String):
	PopupManager.create_popup(text, global_position, popup_color, outline_color)
