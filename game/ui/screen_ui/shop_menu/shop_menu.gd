class_name ShopMenu
extends ScreenMenu

const SHOP_CARD = preload("res://ui/screen_ui/shop_menu/shop_card/shop_card.tscn")

@onready var back_button: Button = %BackButton
@onready var tree_cards: HBoxContainer = %TreeCards
@onready var power_cards: HBoxContainer = %PowerCards
@onready var detail_panel: ShopDetailPanel = %DetailPanel
@onready var cost_label: RichTextLabel = %CostLabel
@onready var purchase_button: Button = %PurchaseButton

@export var initial_tree_cards: Array[Global.TreeType]

# For open/close tweens
var starting_position := position

var currently_selected_card: ShopCard = null
var purchased_cards: Array[Global.TreeType] = []

signal on_tree_purchased(twee: Twee)

func _ready():
	show_card_details(null)
	
	_connect_button_signals()
	
	reset_shop_cards()

func _connect_button_signals():
	back_button.pressed.connect(_on_back_button_pressed)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

func _on_back_button_pressed():
	ScreenUI.exit_menu()

func _on_purchase_button_pressed():
	if not TreeManager.enough_n(currently_selected_card.tree_stat.cost_to_purchase):
		SfxManager.play_sound_effect("ui_fail")
		return
	
	TreeManager.consume_n(currently_selected_card.tree_stat.cost_to_purchase)
	
	SfxManager.play_sound_effect("ui_click")
	TreeMenu.instance.add_tree_card(currently_selected_card.tree_type)
	
	remove_card(currently_selected_card)
	show_card_details(null)
	
	purchased_cards.append(currently_selected_card.tree_type)

func _on_shop_card_pressed(shop_card: ShopCard):
	if currently_selected_card != null:
		currently_selected_card.deselect()
	
	if currently_selected_card == shop_card:
		currently_selected_card = null
		show_card_details(null)
		return
	
	currently_selected_card = shop_card
	shop_card.select()
	
	show_card_details(shop_card)



func show_card_details(shop_card: ShopCard):
	if shop_card == null:
		purchase_button.disabled = true
		cost_label.text = ""
	else:
		purchase_button.disabled = false
		cost_label.text = "Cost: " + str(shop_card.tree_stat.cost_to_purchase)
	
	detail_panel.set_details(shop_card)

func reset_shop_cards():
	currently_selected_card = null
	purchased_cards = []
	
	for shop_card in tree_cards.get_children():
		shop_card.queue_free()
	
	for tree_type in initial_tree_cards:
		var shop_card = SHOP_CARD.instantiate()
		shop_card.tree_type = tree_type
		shop_card.pressed.connect(_on_shop_card_pressed.bind(shop_card))
		
		tree_cards.add_child(shop_card)

func remove_card(shop_card: ShopCard):
	shop_card.remove()

func disable_card_of_type(tree_type: Global.TreeType):
	for shop_card: ShopCard in tree_cards.get_children():
		if shop_card.tree_type == tree_type:
			remove_card(shop_card)
	
	for shop_card: ShopCard in power_cards.get_children():
		if shop_card.tree_type == tree_type:
			remove_card(shop_card)




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

## Pauses the game
func pause_game() -> void:
	Global.pause_game()
	
	var filter := AudioEffectLowPassFilter.new()
	filter.cutoff_hz = 800.0
	AudioServer.add_bus_effect(AudioServer.get_bus_index("Music"), filter, 0)
	
	NutreentsDiscordRPC.update_details("Shopping for saplings")
	
	show()
	back_button.grab_focus() ## TEMP: So controller can navigate the menu...

func unpause_game() -> void:
	Global.unpause_game()
	
	NutreentsDiscordRPC.update_details("Growing a forest")
	
	if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)
	
	hide()

#endregion
