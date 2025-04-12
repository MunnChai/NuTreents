class_name WaterHighlight
extends OverlayHighlight

@onready var label: RichTextLabel = $Label

func set_label_number(number: float): 
	var sign := "+" if number >= 0 else "" # Godot ternary is so ugly
	
	label.text = sign + str(int(number))
	
	label.add_theme_color_override("default_color", Color.WHITE)
	if (number < 0):
		label.add_theme_color_override("default_color", Color.ORANGE_RED)
