class_name ResearchMenu
extends ScreenMenu

@onready var back_button: Button = %BackButton
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var research_tree: ResearchTree = %ResearchTree
@onready var detail_panel: ResearchDetailPanel = %DetailPanel
@onready var tech_points_label: RichTextLabel = %TechPointsLabel

@onready var starting_position = position

var target_v_scroll: float
var currently_selected_node: ResearchNode

func _ready():
	_connect_button_signals()
	await get_tree().process_frame
	_on_num_tech_points_changed(research_tree.num_tech_points)

func _process(delta: float) -> void:
	scroll_container.scroll_vertical = MathUtil.decay(scroll_container.scroll_vertical, target_v_scroll, 10, delta)

func _connect_button_signals():
	back_button.pressed.connect(_on_back_button_pressed)
	
	var research_nodes: Array[ResearchNode] = research_tree.get_research_nodes()
	for research_node: ResearchNode in research_nodes:
		research_node.pressed.connect(_on_research_node_pressed)
		research_node.focused.connect(_on_research_node_focused)
	
	research_tree.num_tech_points_changed.connect(_on_num_tech_points_changed)
	research_tree.unlock_failed.connect(_on_unlock_failed)
	research_tree.unlock_success.connect(_on_unlock_success)

func _on_back_button_pressed():
	ScreenUI.exit_menu()

func _on_research_node_pressed(research_node: ResearchNode) -> void:
	if currently_selected_node:
		currently_selected_node.deselect()
	
	research_node.select()
	currently_selected_node = research_node
	
	detail_panel.set_details(research_node)

func _on_research_node_focused(research_node: ResearchNode) -> void:
	target_v_scroll = research_node.get_parent().position.y - 165 ## Manual scroll offset.. kinda scuffed

func _on_num_tech_points_changed(tech_points: int) -> void:
	tech_points_label.text = str(tech_points)

func _on_unlock_failed(research_node: ResearchNode) -> void:
	tech_points_label.text = "[shake rate=20.0 level=20 connected=1][color=red]" + str(research_tree.num_tech_points) + "[/color][/shake]"
	await get_tree().create_timer(0.5).timeout
	tech_points_label.text = str(research_tree.num_tech_points)

func _on_unlock_success(research_node: ResearchNode) -> void:
	detail_panel.set_details(research_node)

#region Menu Opening/Closing

func open(previous_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	pause_game()
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = starting_position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)
	
	# Set scroll to center
	await get_tree().process_frame
	var root_node: ResearchNode = research_tree.get_root_node()
	_on_research_node_focused(root_node)
	scroll_container.scroll_vertical = target_v_scroll

func close(next_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)

func _finish_close():
	unpause_game()

#endregion


#region Pausing

func pause_game():
	Global.pause_game()
	var filter := AudioEffectLowPassFilter.new()
	filter.cutoff_hz = 800.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), filter, 0)
	NutreentsDiscordRPC.instance.update_details("Shopping for saplings")
	show()
	back_button.grab_focus()

func unpause_game():
	Global.unpause_game()
	NutreentsDiscordRPC.instance.update_details("Growing a forest")
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	hide()

#endregion
