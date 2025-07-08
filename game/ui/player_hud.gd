class_name PlayerHUD
extends CanvasLayer

func _ready() -> void:
	DebugConsole.register("toggle_hud", func(args: PackedStringArray):
		visible = !visible
		, "Toggles player hud visibility")

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("debug_button_2"):
		#visible = !visible
