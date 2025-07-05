class_name AlmanacMenu
extends ScreenMenu

const ALMANAC_TREE_CARD = preload("res://ui/screen_ui/almanac_menu/almanac_card/almanac_tree_card.tscn")
const ALMANAC_ENEMY_CARD = preload("res://ui/screen_ui/almanac_menu/almanac_card/almanac_enemy_card.tscn")

@onready var back_button = %BackButton
@onready var tree_menu = %TreeGrid
@onready var enemy_menu = %EnemyGrid
@onready var tabs = %Tabs
@onready var details: AlmanacDetailPanel = %Details

var starting_position := position

var currently_selected_card: AlmanacCardBase = null
var previous_time_scale: float
var is_paused: bool

func _ready() -> void:
	connect_signals()
	show_card_details(null)

func connect_signals():
	back_button.pressed.connect(on_back_button_pressed)
	tabs.tab_changed.connect(update_menu)
	

func clear_menus():
	for card in tree_menu.get_children():
		card.queue_free()
	for card in enemy_menu.get_children():
		card.queue_free()

func update_menu(tab: int):
	clear_menus()
	show_card_details(null)
	if tab == 0:
		populate_tree_menu()
	else:
		populate_enemy_menu()

func populate_tree_menu():
	var trees: Array[Global.TreeType] = AlmanacInfo.get_trees()
	print("open almanac", trees)
	for t in trees:
		var card: AlmanacTreeCard = ALMANAC_TREE_CARD.instantiate()
		card.type = t
		card.pressed.connect(_on_card_pressed.bind(card))
		tree_menu.add_child(card)
	
func populate_enemy_menu():
	var enemies: Array[Global.EnemyType] = AlmanacInfo.get_enemies()
	for e in enemies:
		var card: AlmanacEnemyCard = ALMANAC_ENEMY_CARD.instantiate()
		card.type = e
		card.pressed.connect(_on_card_pressed.bind(card))
		enemy_menu.add_child(card)

func _on_card_pressed(card: AlmanacCardBase):
	if currently_selected_card != null:
		currently_selected_card.deselect()
	
	if currently_selected_card == card:
		currently_selected_card = null
		show_card_details(null)
		return
	
	currently_selected_card = card
	card.select()
	
	show_card_details(card)

func show_card_details(card: AlmanacCardBase):
	if card == null:
		details.set_card(null)
		return
		
	details.set_card(card)

func open(previous_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	pause_game()
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)
	update_menu(tabs.current_tab)

func close(next_menu: ScreenMenu):
	SfxManager.play_sound_effect("ui_pages")
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)

func _finish_close():
	clear_menus()
	unpause_game() 

func on_back_button_pressed():
	ScreenUI.exit_menu()

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
