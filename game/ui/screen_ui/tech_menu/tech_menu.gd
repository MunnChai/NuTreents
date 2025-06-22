class_name TechMenu
extends Control
 
@onready var container = $HBoxContainer

@onready var rocket_body: TextureRect = %RocketBody
@onready var rocket_fuel: TextureRect = %RocketFuel
@onready var rocket_wings: TextureRect = %RocketWings
@onready var win_button: Button = %WinButton

enum TechSlot {
	BODY,
	FUEL,
	WINGS
}

const OBTAINED_ICON_MODULATE := Color.WHITE
const UNOBTAINED_ICON_MODULATE := Color("5a5a5a")

var unassigned_tech: Array = TechSlot.values()
var current_tech: Array[TechSlot] = []

var starting_position = position

var is_currently_animating := false
var is_mouse_inside := false

func open() -> void:
	SfxManager.play_sound_effect("ui_click")
	
	## ANIMATION
	TweenUtil.pop_delta(container, Vector2(0, -0.05), 0.3)
	TweenUtil.whoosh(self, starting_position, 0.4)

func close() -> void:
	TweenUtil.pop_delta(container, Vector2(0, -0.05), 0.3)
	TweenUtil.whoosh(self, starting_position + Vector2.LEFT * 125.0, 0.4)


func _ready():
	
	close()

func _process(delta: float) -> void:
	update_icons()
	check_victory_condition()

func update_icons():
	if (current_tech.has(TechSlot.BODY)):
		rocket_body.modulate = OBTAINED_ICON_MODULATE
	else:
		rocket_body.modulate = UNOBTAINED_ICON_MODULATE
	if (current_tech.has(TechSlot.FUEL)):
		rocket_fuel.modulate = OBTAINED_ICON_MODULATE
	else:
		rocket_fuel.modulate = UNOBTAINED_ICON_MODULATE
	if (current_tech.has(TechSlot.WINGS)):
		rocket_wings.modulate = OBTAINED_ICON_MODULATE
	else:
		rocket_wings.modulate = UNOBTAINED_ICON_MODULATE

func check_victory_condition():
	if (current_tech.has(TechSlot.BODY) && current_tech.has(TechSlot.FUEL) && current_tech.has(TechSlot.WINGS)):
		win_button.disabled = false
	else:
		win_button.disabled = true


func click_victory():
	SessionData.save_session_data(Global.session_id)
	Global.game_state = Global.GameState.VICTORY
	SceneLoader.transition_to_victory_screen()


func _on_mouse_entered():
	open()


func _on_mouse_exited():
	close()
