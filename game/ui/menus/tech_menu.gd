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

var unassigned_tech: Array[TechSlots]

var current_tech: Array[TechSlots]

func _ready():
	unassigned_tech = [TechSlots.BODY, TechSlots.FUEL, TechSlots.WINGS]
	current_tech = []

func _process(delta: float) -> void:
	
	var text = "Technology Required: \n"
	if (current_tech.has(TechSlots.BODY)):
		rocket_body.modulate = Color.WHITE
	else:
		text += "- Rocket Body \n"
		rocket_body.modulate = Color("5a5a5a")
	if (current_tech.has(TechSlots.FUEL)):
		rocket_fuel.modulate = Color.WHITE
	else:
		text += "- Rocket Fuel \n"
		rocket_fuel.modulate = Color("5a5a5a")
	if (current_tech.has(TechSlots.WINGS)):
		rocket_wings.modulate = Color.WHITE
	else:
		text += "- Rocket Wings \n"
		rocket_wings.modulate = Color("5a5a5a")
	
	check_victory()

func check_victory():
	if (current_tech.has(TechSlots.BODY) && current_tech.has(TechSlots.FUEL) && current_tech.has(TechSlots.WINGS)):
		win_button.disabled = false
	else:
		win_button.disabled = true


func click_victory():
	Global.game_state = Global.GameState.VICTORY
	SceneLoader.transition_to_victory_screen()
