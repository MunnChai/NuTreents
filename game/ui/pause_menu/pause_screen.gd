class_name PauseScreen
extends Control

## BUGS
## BUG: Fade in black screen is on a higher layer than the pause screen
## BUG: Pause menu shadow is hidden behind tree menu

var can_pause := true

@onready var pause_menu: PauseMenu = %PauseMenu
@onready var pause_menu_offset = %PauseMenuOffset
@onready var dimmer: ColorRect = %Dimmer

@onready var dimmer_opacity := dimmer.modulate.a

func _ready() -> void:
	pause_menu.game_paused.connect(_on_game_paused)
	pause_menu.game_resumed.connect(_on_game_resumed)
	pause_menu.unpause_game()

func _process(delta: float) -> void:
	if can_pause:
		if Input.is_action_just_pressed("pause"):
			pause_menu.toggle_pause()

func _on_game_paused() -> void:
	show()
	
	pause_menu_offset.position = Vector2.DOWN * 50.0
	create_tween().tween_property(pause_menu_offset, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	pause_menu_offset.modulate.a = 0
	create_tween().tween_property(pause_menu_offset, "modulate", Color(pause_menu_offset.modulate, 1), 0.1)
	
	dimmer.modulate.a = 0
	create_tween().tween_property(dimmer, "modulate", Color(dimmer.modulate, dimmer_opacity), 0.1)

func _on_game_resumed() -> void:
	hide()
	
	## TODO: Reverse the opening animation upon closing... but terminate if re-opened immediately afterward!
