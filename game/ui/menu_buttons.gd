extends Control
 
@onready var almanac_button = %AlmanacButton
@onready var research_button = %ResearchButton

var shop_menu: ScreenMenu

func _ready():
	_connect_button_signals() 

func _connect_button_signals():
	research_button.pressed.connect(_on_research_button_pressed)
	almanac_button.pressed.connect(_on_almanac_button_pressed)

func _on_research_button_pressed():
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.add_menu(ScreenUI.research_menu)

func _on_almanac_button_pressed():
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.add_menu(ScreenUI.almanac_menu)
