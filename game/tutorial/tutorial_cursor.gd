extends Cursor

var is_visible: bool = true

func _process(delta: float) -> void:
	if not is_visible:
		return
	
	super._process(delta)
