class_name PlayerHUD
extends CanvasLayer

func _ready() -> void:
	DebugConsole.register("toggle_hud", func(args: PackedStringArray):
		visible = !visible
		, "Toggles player hud visibility")
