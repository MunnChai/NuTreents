extends Control
 
@onready var almanac_button = %AlmanacButton
@onready var shop_button = %ShopButton

var shop_menu: ScreenMenu

func _ready():
	_connect_button_signals() 

func _connect_button_signals():
	shop_button.pressed.connect(_on_shop_button_pressed)
	almanac_button.pressed.connect(_on_almanac_button_pressed)

func _on_shop_button_pressed():
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.add_menu(ScreenUI.shop_menu)

func _on_almanac_button_pressed():
	SfxManager.play_sound_effect("ui_click")
	pass
