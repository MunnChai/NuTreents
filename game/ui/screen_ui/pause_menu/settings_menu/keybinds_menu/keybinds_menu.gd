class_name KeybindsMenu
extends ScreenMenu

## TODO
## - Log changes, and ask for confirmation upon exiting...

## SCREEN MENU IMPLEMENTATION

@onready var starting_position := position

func open(previous_menu: ScreenMenu) -> void:
	position = starting_position
	show()
	
	SfxManager.play_sound_effect("ui_click")
	
	## ANIMATION
	TweenUtil.pop_delta(self, Vector2(-0.3, 0.3), 0.3)
	position = position + Vector2.DOWN * 100.0
	TweenUtil.whoosh(self, starting_position, 0.4)
	TweenUtil.fade(self, 1.0, 0.1)

func close(next_menu: ScreenMenu) -> void:
	TweenUtil.scale_to(self, Vector2(0.9, 1.1), 0.05)
	TweenUtil.whoosh(self, position + Vector2.DOWN * 100.0, 0.4)
	TweenUtil.fade(self, 0.0, 0.1).finished.connect(_finish_close)
func _finish_close() -> void:
	hide()

func return_to(previous_menu: ScreenMenu) -> void:
	if previous_menu == ScreenUI.confirmation_menu:
		return
	
	## ANIMATION
	open(previous_menu)

## KEYBIND REMAPPING

static var instance: KeybindsMenu
var is_rebinding := false

func _ready() -> void:
	instance = self
	is_rebinding = false

var just_rebinded := false
func _process(delta: float) -> void:
	if is_rebinding:
		if not just_rebinded:
			ScreenUI.keybinding_dimmer.show()
		just_rebinded = true
		%BackButton.disabled = true
	else:
		if just_rebinded:
			ScreenUI.keybinding_dimmer.hide()
		just_rebinded = false
		%BackButton.disabled = false

func _on_back_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.exit_menu()

func _on_reset_choice(choice: bool) -> void:
	if choice:
		for child in %KeybindContainer.get_children():
			if child is KeybindLine:
				child.reset_value()
				SfxManager.play_sound_effect("ui_pages")
	else:
		SfxManager.play_sound_effect("ui_click")

func _prompt_for_reset() -> void:
	ScreenUI.add_menu(ScreenUI.confirmation_menu)
	ScreenUI.confirmation_menu.set_message("Are you sure you want to reset all keybinds to defaults?")
	ScreenUI.confirmation_menu.set_accept_text("Yes, Reset")
	ScreenUI.confirmation_menu.set_decline_text("No, Keep Existing")
	ScreenUI.confirmation_menu.connect_choice_to(_on_reset_choice)
	await ScreenUI.confirmation_menu.choice_made

func _on_reset_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	await _prompt_for_reset()
