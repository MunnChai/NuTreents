extends Control
 
@onready var almanac_button = %AlmanacButton
@onready var research_button = %ResearchButton
@onready var destroy_button: Button = %DestroyButton

var shop_menu: ScreenMenu

func _ready():
	_connect_button_signals()

func _connect_button_signals():
	research_button.pressed.connect(_on_research_button_pressed)
	almanac_button.pressed.connect(_on_almanac_button_pressed)
	destroy_button.pressed.connect(_on_destroy_button_pressed)

func _on_research_button_pressed():
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.add_menu(ScreenUI.research_menu)

func _on_almanac_button_pressed():
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.add_menu(ScreenUI.almanac_menu)

func _on_destroy_button_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	if IsometricCursor.instance.get_current_state() == IsometricCursor.CursorState.DESTROY:
		IsometricCursor.instance.return_to_default_state()
	else:
		IsometricCursor.instance.enter_state(IsometricCursor.CursorState.DESTROY)
