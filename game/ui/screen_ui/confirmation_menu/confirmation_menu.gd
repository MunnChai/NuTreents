class_name ConfirmationMenu
extends ScreenMenu

signal accepted
signal declined
signal choice_made(choice: bool)

## REFERENCES
@onready var message: RichTextLabel = %Message
@onready var accept_button: ScreenButton = %AcceptButton
@onready var decline_button: ScreenButton = %DeclineButton
@onready var back_button: ScreenButton = %BackButton

@onready var starting_position := position

func _ready() -> void:
	hide()
	modulate.a = 0
	
	accept_button.pressed.connect(_accept_pressed)
	decline_button.pressed.connect(_decline_pressed)
	back_button.pressed.connect(_back_pressed)

func _accept_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.exit_menu()
	accepted.emit()
	choice_made.emit(true)

func _decline_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.exit_menu()
	declined.emit()
	choice_made.emit(false)

func _back_pressed() -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	ScreenUI.exit_menu()

## SCREEN MENU IMPLEMENTATION

func open(previous_menu: ScreenMenu) -> void:
	show()
	ScreenUI.confirmation_dimmer.show()
	## ANIMATION
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)
func close(next_menu: ScreenMenu) -> void:
	ScreenUI.confirmation_dimmer.hide()
	TweenUtil.pop_delta(self, Vector2(-0.1, 0.1), 0.3)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)
func _finish_close() -> void:
	hide()

## No return to implementation because this menu shouldn't open any new ones...

func connect_choice_to(choice_handler: Callable) -> void:
	for sig in choice_made.get_connections():
		choice_made.disconnect(sig.callable)
	choice_made.connect(choice_handler)

func reset_button_text() -> void:
	set_accept_text("Yes")
	set_decline_text("No")

func set_message(content: String) -> void:
	message.text = content

func set_accept_text(content: String) -> void:
	accept_button.text = content
func set_decline_text(content: String) -> void:
	decline_button.text = content
