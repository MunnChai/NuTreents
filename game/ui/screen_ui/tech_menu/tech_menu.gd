class_name TechMenu
extends Control

@onready var requirements_label: RichTextLabel = %RequirementsLabel
@onready var win_button: Button = %WinButton
@onready var rocket_body: TextureRect = %RocketBody
@onready var rocket_fuel: TextureRect = %RocketFuel
@onready var rocket_wings: TextureRect = %RocketWings

enum TechSlots {
	BODY,
	FUEL,
	WINGS
}

const OBTAINED_ICON_MODULATE := Color.WHITE
const UNOBTAINED_ICON_MODULATE := Color("5a5a5a")

var unassigned_tech: Array[TechSlots]

var current_tech: Array[TechSlots]

func _ready():
	unassigned_tech = [TechSlots.BODY, TechSlots.FUEL, TechSlots.WINGS]
	current_tech = []

func _process(delta: float) -> void:
	update_icons()
	check_victory_condition()

func update_icons():
	if (current_tech.has(TechSlots.BODY)):
		rocket_body.modulate = OBTAINED_ICON_MODULATE
	else:
		rocket_body.modulate = UNOBTAINED_ICON_MODULATE
	if (current_tech.has(TechSlots.FUEL)):
		rocket_fuel.modulate = OBTAINED_ICON_MODULATE
	else:
		rocket_fuel.modulate = UNOBTAINED_ICON_MODULATE
	if (current_tech.has(TechSlots.WINGS)):
		rocket_wings.modulate = OBTAINED_ICON_MODULATE
	else:
		rocket_wings.modulate = UNOBTAINED_ICON_MODULATE

func check_victory_condition():
	if (current_tech.has(TechSlots.BODY) && current_tech.has(TechSlots.FUEL) && current_tech.has(TechSlots.WINGS)):
		win_button.disabled = false
	else:
		win_button.disabled = true


func click_victory():
	Global.game_state = Global.GameState.VICTORY
	SceneLoader.transition_to_victory_screen()
