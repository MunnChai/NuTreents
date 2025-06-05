class_name KeybindLine
extends HBoxContainer

## TODO
## - Handle "multiple keys" per ACTION
## - Deal with gamepad alternate controls
## - Avoid duplication within "sets"

## Ref to good video exploring rebinding: 
## https://www.youtube.com/watch?v=8evy-oafO8c&ab_channel=Pmk

@export var input_binding_id: String = "lmb"
@export var display_name: String = "Plant/Place"

# Default events associated with action of input_binding_id
# BEFORE settings are loaded into memory
var defaults: Array

# Currently rebinding THIS ACTION specifically?
var currently_rebinding := false

func _ready() -> void:
	# Load defaults... (and duplicate)
	## NOTE/BUG: Currently, make sure each input_binding_id only has ONE KeybindLine...
	## Otherwise, the defaults will end up being saved as the loaded values...
	defaults = InputMap.action_get_events(input_binding_id).duplicate()
	
	# Load settings now...
	load_from_settings()
	reset_labels()
	
	$RebindButton.pressed.connect(_on_pressed)
	currently_rebinding = false

func _process(delta: float) -> void:
	if KeybindsMenu.instance.is_rebinding and not currently_rebinding:
		$RebindButton.disabled = true
		$CurrentKey.modulate.a = 0.5
	else:
		$RebindButton.disabled = false
		$CurrentKey.modulate.a = 1.0

func reset_labels() -> void:
	$RebindButton.text = display_name
	$CurrentKey.text = get_current_keys()[0]

## Retrieves an array of key event names with " (Physical)" suffix removed
func get_current_keys() -> Array:
	var events = InputMap.action_get_events(input_binding_id)
	#print(events)
	var result = []
	for event: InputEvent in events:
		result.append(event.as_text().trim_suffix(" (Physical)"))
	return result

#region REBIND INTERACTION

func _on_pressed() -> void:
	if KeybindsMenu.instance.is_rebinding:
		return
	await_rebind()

## Sets the state to rebinding, for _input to handle actually getting the new event
func await_rebind() -> void:
	$CurrentKey.text = "<AWAITING INPUT>"
	currently_rebinding = true
	KeybindsMenu.instance.is_rebinding = true
	SfxManager.play_sound_effect("ui_click")

func _input(event) -> void:
	if currently_rebinding:
		## NOTE: Currently does not support gamepad!
		if event is InputEventKey || event is InputEventMouseButton:
			if event.is_released():
				# Get current "first" key
				var old_key = InputMap.action_get_events(input_binding_id)[0]
				
				# Get all keys, remove first key, add new key to front
				var all_keys = InputMap.action_get_events(input_binding_id)
				all_keys.erase(old_key)
				all_keys.push_front(event)
				
				# Clear key list and then add all the elements of modified key list back
				InputMap.action_erase_events(input_binding_id)
				for key in all_keys:
					InputMap.action_add_event(input_binding_id, key)
				
				reset_labels()
				
				# Rebinding is over!
				currently_rebinding = false
				KeybindsMenu.instance.is_rebinding = false
				
				SfxManager.play_sound_effect("ui_click")
				
				save_to_settings()

#endregion

#region SAVE/LOAD/RESET

## Clear InputMap for this specific action id and set the defaults from game startup
## Also SAVES the default values back to config
func reset_value() -> void:
	InputMap.action_erase_events(input_binding_id)
	
	for key in defaults:
		InputMap.action_add_event(input_binding_id, key)
	
	save_to_settings()
	reset_labels()

## Save (this specific action id) from InputMap into settings config
func save_to_settings() -> void:
	Settings.set_control_setting(input_binding_id, InputMap.action_get_events(input_binding_id))
	Settings.save_to_config()

## Load (this specific action id) from settings into InputMap
func load_from_settings() -> void:
	var all_keys = Settings.get_control_setting_or_default(input_binding_id, null)
	
	if not all_keys:
		return
	
	InputMap.action_erase_events(input_binding_id)
	
	for key in all_keys:
		InputMap.action_add_event(input_binding_id, key)

#endregion
