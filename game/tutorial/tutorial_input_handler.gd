extends InputHandler

var is_enabled: bool = false

func _process(delta: float) -> void:
	if not is_enabled:
		return
	
	super._process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not is_enabled:
		return
	
	super._unhandled_input(event)
