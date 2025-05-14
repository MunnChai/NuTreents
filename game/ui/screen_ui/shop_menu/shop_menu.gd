class_name ShopMenu
extends ScreenMenu

@onready var back_button = %BackButton

var is_paused: bool
var previous_time_scale: float

var starting_position := position

func _ready():
	_connect_button_signals()

func _connect_button_signals():
	back_button.pressed.connect(_on_back_button_pressed)

func open(previous_menu: ScreenMenu):
	pause_game()
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)

func close(next_menu: ScreenMenu):
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)

func _finish_close():
	unpause_game() 


## Pauses the game
func pause_game() -> void:
	is_paused = true
	get_tree().paused = true 
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = true
	
	previous_time_scale = Engine.time_scale
	Engine.time_scale = 1.0
	
	var filter := AudioEffectLowPassFilter.new()
	filter.cutoff_hz = 800.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), filter, 0)
	
	NutreentsDiscordRPC.update_details("Shopping for saplings")
	
	show()
	back_button.grab_focus() ## TEMP: So controller can navigate the menu...

func unpause_game() -> void:
	Engine.time_scale = previous_time_scale
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = false
	
	is_paused = false
	get_tree().paused = false 
	
	NutreentsDiscordRPC.update_details("Growing a forest")
	
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	
	hide()

func _on_back_button_pressed():
	ScreenUI.exit_menu()
