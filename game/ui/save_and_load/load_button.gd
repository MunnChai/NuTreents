extends PanelContainer

@onready var button: Button = $Button
@onready var save_num_label: RichTextLabel = %SaveNumLabel
@onready var time_played_label: RichTextLabel = %TimePlayedLabel
@onready var seed_label: RichTextLabel = %SeedLabel

func set_button_info(save_num: int, session_data: Dictionary): 
	if session_data.is_empty():
		set_button_info_empty(save_num)
		return
	
	save_num_label.text = "Save File " + str(save_num)
	seed_label.text = "Seed: " + str(session_data["seed"])

func set_button_info_empty(save_num: int):
	button.disabled = true
	save_num_label.text = "Save File " + str(save_num)
	time_played_label.text = ""
	seed_label.text = ""
