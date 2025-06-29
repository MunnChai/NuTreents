class_name BiomeOverlay
extends CanvasLayer

func _ready() -> void:
	$Desert.show()
	$Snowy.hide()

func _process(delta: float) -> void:
	pass
