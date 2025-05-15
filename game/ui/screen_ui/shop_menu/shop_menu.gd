class_name ShopMenu
extends ScreenMenu

@onready var back_button: Button = %BackButton
@onready var tree_cards: HBoxContainer = %TreeCards
@onready var power_cards: HBoxContainer = %PowerCards
@onready var detail_panel: ShopDetailPanel = %DetailPanel
@onready var purchase_button: Button = %PurchaseButton

# Pasuing Stuff
var is_paused: bool
var previous_time_scale: float

# For open/close tweens
var starting_position := position

var currently_selected_card: ShopCard = null

signal on_tree_purchased(twee: Twee)

func _ready():
	show_card_details(null)
	
	_connect_button_signals()

func _connect_button_signals():
	for shop_card: ShopCard in tree_cards.get_children():
		shop_card.pressed.connect(_on_shop_card_pressed.bind(shop_card))
	
	for shop_card: ShopCard in power_cards.get_children():
		shop_card.pressed.connect(_on_shop_card_pressed.bind(shop_card))
	
	back_button.pressed.connect(_on_back_button_pressed)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

func _on_back_button_pressed():
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.exit_menu()

func _on_purchase_button_pressed():
	# TODO: Check and decrement nutreent cost of cards
	
	SfxManager.play_sound_effect("ui_click")
	TreeMenu.instance.add_tree_card(currently_selected_card.tree_type)
	
	disable_card(currently_selected_card)
	show_card_details(null)

func _on_shop_card_pressed(shop_card: ShopCard):
	if currently_selected_card != null:
		currently_selected_card.deselect()
	
	currently_selected_card = shop_card
	shop_card.select()
	
	show_card_details(shop_card)

func show_card_details(shop_card: ShopCard):
	if shop_card == null:
		purchase_button.disabled = true
	else:
		purchase_button.disabled = false
	
	detail_panel.set_details(shop_card)

func disable_card(shop_card: ShopCard):
	shop_card.disable()

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


#region Pausing

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

#endregion
