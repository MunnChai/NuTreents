class_name AlmanacMenu
extends ScreenMenu

@onready var back_button = %BackButton

var starting_position := position

@export var category_container: VBoxContainer
@export var entry_container: HBoxContainer
@export var detail_panel: Control

enum FocusArea { CATEGORIES, ENTRIES }
var _current_focus_area: FocusArea = FocusArea.CATEGORIES
var _focused_category_index: int = 0
var _focused_entry_index: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return

	if event.is_action_pressed("menu_right") or event.is_action_pressed("menu_left"):
		_switch_focus_area()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		ScreenUI.exit_menu()
		get_viewport().set_input_as_handled()
	else:
		if _current_focus_area == FocusArea.CATEGORIES:
			_handle_category_navigation(event)
		else:
			_handle_entry_navigation(event)

func _handle_category_navigation(event: InputEvent):
	var new_index = _focused_category_index
	if event.is_action_pressed("down"): new_index += 1
	elif event.is_action_pressed("up"): new_index -= 1
	new_index = clamp(new_index, 0, category_container.get_child_count() - 1)
	if new_index != _focused_category_index:
		_focused_category_index = new_index
		_update_category_focus()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("lmb"):
		_populate_entry_view_for_category(_focused_category_index)
		_switch_focus_area()
		get_viewport().set_input_as_handled()

func _handle_entry_navigation(event: InputEvent):
	var new_index = _focused_entry_index
	if event.is_action_pressed("right"): new_index += 1
	elif event.is_action_pressed("left"): new_index -= 1
	new_index = clamp(new_index, 0, entry_container.get_child_count() - 1)
	if new_index != _focused_entry_index:
		_focused_entry_index = new_index
		_update_entry_focus()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("lmb"):
		if entry_container.get_child_count() > _focused_entry_index:
			_display_entry_details(entry_container.get_child(_focused_entry_index))
			get_viewport().set_input_as_handled()

func _switch_focus_area():
	_current_focus_area = FocusArea.ENTRIES if _current_focus_area == FocusArea.CATEGORIES else FocusArea.CATEGORIES
	_update_category_focus()
	_update_entry_focus()

func _update_category_focus():
	for i in category_container.get_child_count():
		var child = category_container.get_child(i)
		child.modulate = Color.YELLOW if i == _focused_category_index and _current_focus_area == FocusArea.CATEGORIES else Color.WHITE

func _update_entry_focus():
	for i in entry_container.get_child_count():
		var child = entry_container.get_child(i)
		child.modulate = Color.YELLOW if i == _focused_entry_index and _current_focus_area == FocusArea.ENTRIES else Color.WHITE

func _populate_entry_view_for_category(category_index: int):
	# TODO: Your logic to clear entry_container and fill it with items
	pass

func _display_entry_details(entry_node: Node):
	# TODO: Your logic to display data from the entry node in the detail_panel
	pass
	
func open(previous_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	pause_game()
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
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
	NutreentsDiscordRPC.update_details("Researching tree things...")
	show()
	back_button.grab_focus()

func unpause_game():
	Global.unpause_game()
	NutreentsDiscordRPC.update_details("Growing a forest")
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	hide()
#endregion
