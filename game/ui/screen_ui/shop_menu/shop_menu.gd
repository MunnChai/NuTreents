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

var starting_position := position

# --- Controller Support Variables ---
enum FocusArea { CARDS, BUTTONS }
var _current_focus_area: FocusArea = FocusArea.CARDS
var _focused_card_index: int = 0
var _active_card_container: HBoxContainer

var currently_selected_card: ShopCard = null
var purchased_cards: Array[Global.TreeType] = []

signal on_tree_purchased(twee: Twee)

func _ready():
	show_card_details(null)
	_connect_button_signals()
	reset_shop_cards()

# --- BUG FIX ---
# The check for the "pause" action has been removed from this script.
# The global UI manager (ScreenUI.gd) is already responsible for handling the
# "back" action. This menu was interfering by also trying to handle it,
# which caused the double-action bug.
func _input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return

	if event.is_action_pressed("menu_right") or event.is_action_pressed("menu_left"):
		_switch_focus_area()
		get_viewport().set_input_as_handled()
	# The "pause" event is no longer handled here.
	else:
		if _current_focus_area == FocusArea.CARDS:
			_handle_card_navigation(event)

func _handle_card_navigation(event: InputEvent):
	if not is_instance_valid(_active_card_container) or _active_card_container.get_child_count() == 0:
		_switch_focus_area()
		return
		
	var new_index = _focused_card_index
	if event.is_action_pressed("right"): new_index += 1
	elif event.is_action_pressed("left"): new_index -= 1
	elif event.is_action_pressed("down"): _switch_card_container(power_cards)
	elif event.is_action_pressed("up"): _switch_card_container(tree_cards)
	
	new_index = clamp(new_index, 0, _active_card_container.get_child_count() - 1)
	if new_index != _focused_card_index:
		_focused_card_index = new_index
		_update_card_focus()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("lmb"):
		var card = _active_card_container.get_child(_focused_card_index)
		_on_shop_card_pressed(card)
		get_viewport().set_input_as_handled()

func _switch_focus_area():
	if _current_focus_area == FocusArea.CARDS:
		_current_focus_area = FocusArea.BUTTONS
		_clear_card_focus()
		if purchase_button.disabled:
			back_button.grab_focus()
		else:
			purchase_button.grab_focus()
	else:
		_current_focus_area = FocusArea.CARDS
		_update_card_focus()
		
func _switch_card_container(target_container: HBoxContainer):
	if _active_card_container != target_container:
		if currently_selected_card: currently_selected_card.deselect()
		_active_card_container = target_container
		_focused_card_index = 0
		_update_card_focus()

func _update_card_focus():
	_clear_card_focus()
	if _active_card_container.get_child_count() > _focused_card_index:
		var card_to_focus = _active_card_container.get_child(_focused_card_index)
		card_to_focus.select()

func _clear_card_focus():
	for container in [tree_cards, power_cards]:
		for card in container.get_children():
			card.deselect()

func _connect_button_signals():
	back_button.pressed.connect(_on_back_button_pressed)
	purchase_button.pressed.connect(_on_purchase_button_pressed)

func _on_back_button_pressed():
	ScreenUI.exit_menu()

func _on_purchase_button_pressed():
	if not currently_selected_card: return
	if not TreeManager.enough_n(currently_selected_card.tree_stat.cost_to_purchase):
		SoundManager.play_global_oneshot(&"ui_fail")
		return
	
	TreeManager.consume_n(currently_selected_card.tree_stat.cost_to_purchase)
	SoundManager.play_global_oneshot(&"ui_click")
	TreeMenu.instance.add_tree_card(currently_selected_card.tree_type)
	purchased_cards.append(currently_selected_card.tree_type)
	remove_card(currently_selected_card)
	show_card_details(null)

func _on_shop_card_pressed(shop_card: ShopCard):
	if currently_selected_card == shop_card:
		shop_card.deselect()
		currently_selected_card = null
		show_card_details(null)
	else:
		if currently_selected_card != null:
			currently_selected_card.deselect()
		currently_selected_card = shop_card
		currently_selected_card.select()
		_focused_card_index = shop_card.get_index()
		_active_card_container = shop_card.get_parent()
		show_card_details(shop_card)
	
	_switch_focus_area()

func show_card_details(shop_card: ShopCard):
	purchase_button.disabled = shop_card == null
	cost_label.text = "Cost: " + str(shop_card.tree_stat.cost_to_purchase) if shop_card else ""
	detail_panel.set_details(shop_card)

func reset_shop_cards():
	currently_selected_card = null
	purchased_cards = []
	
	for container in [tree_cards, power_cards]:
		for card in container.get_children():
			card.queue_free()
	
	for tree_type in initial_tree_cards:
		var shop_card = SHOP_CARD.instantiate()
		shop_card.tree_type = tree_type
		shop_card.pressed.connect(_on_shop_card_pressed.bind(shop_card))
		tree_cards.add_child(shop_card)
	
	_active_card_container = tree_cards
	_focused_card_index = 0

func remove_card(shop_card: ShopCard):
	shop_card.remove()

func disable_card_of_type(tree_type: Global.TreeType):
	for container in [tree_cards, power_cards]:
		for card: ShopCard in container.get_children():
			if card.tree_type == tree_type:
				remove_card(card)

func open(previous_menu: ScreenMenu):
	SoundManager.play_global_oneshot(&"ui_pages")
	pause_game()
	_current_focus_area = FocusArea.CARDS
	_update_card_focus()
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = starting_position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)

func close(next_menu: ScreenMenu):
	SoundManager.play_global_oneshot(&"ui_pages")
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
 
