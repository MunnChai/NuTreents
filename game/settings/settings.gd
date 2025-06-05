extends Node

## Autoload for settings information...

var general_settings: Dictionary = {}
var control_settings: Dictionary = {}

func _ready() -> void:
	load_from_config()

func get_control_setting_or_default(key: String, default: Variant) -> Variant:
	return control_settings.get(key, default)

func get_setting_or_default(key: String, default: Variant) -> Variant:
	return general_settings.get(key, default)

func set_control_setting(key: String, value) -> void:
	control_settings.set(key, value)

func set_setting(key: String, value) -> void:
	general_settings.set(key, value)

func save_to_config() -> void:
	var config = ConfigFile.new()
	
	for key: String in general_settings:
		config.set_value("settings", key, general_settings[key])
	
	for key: String in control_settings:
		config.set_value("control", key, control_settings[key])
	
	config.save("user://settings.cfg")

func load_from_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	# Load data from a file.
	var err = config.load("user://settings.cfg")
	# If the file didn't load, ignore it.
	if err != OK:
		return

	for section: String in config.get_sections():
		if section == "control": ## CONTROLS
			for key: String in config.get_section_keys(section):
				var value = config.get_value(section, key)
				if value != null:
					control_settings.set(key, value)
		else: ## GENERAL
			for key: String in config.get_section_keys(section):
				var value = config.get_value(section, key)
				if value != null:
					general_settings.set(key, value)
