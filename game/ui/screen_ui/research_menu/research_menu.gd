class_name ResearchMenu
extends ScreenMenu

@onready var back_button: Button = %BackButton
@onready var research_scroll_container: ScrollContainer = %ResearchScrollContainer
@onready var starting_node: Button = %StartingNode

@onready var starting_position = position

func _ready():
	_connect_button_signals()
	await get_tree().process_frame
	starting_node.grab_focus()

func _connect_button_signals():
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	ScreenUI.exit_menu()

func open(previous_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	pause_game()
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = starting_position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)

func close(next_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)

func _finish_close():
	unpause_game()



#region Pausing
func pause_game():
	Global.pause_game()
	var filter := AudioEffectLowPassFilter.new()
	filter.cutoff_hz = 800.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), filter, 0)
	NutreentsDiscordRPC.update_details("Shopping for saplings")
	show()
	back_button.grab_focus()

func unpause_game():
	Global.unpause_game()
	NutreentsDiscordRPC.update_details("Growing a forest")
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	hide()
#endregion
