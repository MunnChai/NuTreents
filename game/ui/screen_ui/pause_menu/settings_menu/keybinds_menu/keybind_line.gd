class_name KeybindLine
extends HBoxContainer

## TODO
## - Handle "multiple keys" per ACTION
## - Deal with gamepad alternate controls
## - Avoid duplication within "sets"

# Ref to good video exploring rebinding: https://www.youtube.com/watch?v=8evy-oafO8c&ab_channel=Pmk

@export var input_binding_id: String = "lmb"
@export var display_name: String = "Plant/Place"

var defaults

var currently_rebinding := false

func _ready() -> void:
	print(input_binding_id)
	defaults = InputMap.action_get_events(input_binding_id).duplicate()
	print(defaults)
	load_from_settings()
	reset_labels()
	
	$RebindButton.pressed.connect(_on_pressed)
	
	currently_rebinding = false

func reset_labels() -> void:
	$RebindButton.text = display_name
	$CurrentKey.text = get_current_key()[0]

func _on_pressed() -> void:
	if KeybindsMenu.instance.is_rebinding:
		return
	try_rebind()

func _process(delta: float) -> void:
	if KeybindsMenu.instance.is_rebinding and not currently_rebinding:
		$RebindButton.disabled = true
		$CurrentKey.modulate.a = 0.5
	else:
		$RebindButton.disabled = false
		$CurrentKey.modulate.a = 1.0

func try_rebind() -> void:
	$CurrentKey.text = "<AWAITING INPUT>"
	currently_rebinding = true
	KeybindsMenu.instance.is_rebinding = true
	SfxManager.play_sound_effect("ui_click")

func get_current_key() -> Array:
	var events = InputMap.action_get_events(input_binding_id)
	#print(events)
	var result = []
	for event: InputEvent in events:
		result.append(event.as_text().trim_suffix(" (Physical)"))
	return result

func _input(event) -> void:
	if currently_rebinding:
		if event is InputEventKey || event is InputEventMouseButton:
			if event.is_released():
				var old_key = InputMap.action_get_events(input_binding_id)[0]
				
				var all_keys = InputMap.action_get_events(input_binding_id)
				all_keys.erase(old_key)
				all_keys.push_front(event)
				
				#all_keys.reverse()
				
				InputMap.action_erase_events(input_binding_id)
				
				for key in all_keys:
					InputMap.action_add_event(input_binding_id, key)
				
				reset_labels()
				
				currently_rebinding = false
				KeybindsMenu.instance.is_rebinding = false
				
				SfxManager.play_sound_effect("ui_click")
				
				save_to_settings()

func reset_value() -> void:
	InputMap.action_erase_events(input_binding_id)
	
	for key in defaults:
		InputMap.action_add_event(input_binding_id, key)
		print(key)
	
	save_to_settings()
	reset_labels()

func save_to_settings() -> void:
	Settings.set_control_setting(input_binding_id, InputMap.action_get_events(input_binding_id))
	Settings.save_to_config()

func load_from_settings() -> void:
	var all_keys = Settings.get_control_setting_or_default(input_binding_id, null)
	
	if not all_keys:
		return
	
	InputMap.action_erase_events(input_binding_id)
	
	for key in all_keys:
		InputMap.action_add_event(input_binding_id, key)
