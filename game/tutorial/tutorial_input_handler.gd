extends InputHandler

var is_enabled: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_enabled:
		return
	
	super._unhandled_input(event)
