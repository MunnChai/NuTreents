class_name HealthHighlight
extends OverlayHighlight

@onready var label: RichTextLabel = $Label

func set_label_number(number: float): 
	label.text = str(int(number))
