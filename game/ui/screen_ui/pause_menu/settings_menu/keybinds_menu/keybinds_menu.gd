class_name KeybindsMenu
extends ScreenMenu

## TODO
## - Keep a copy of all keybinds JUST AS the menu is opened.
##   Then, on exit, ask for confirmation. 
##   If confirmation declined, reset all keybinds to JUST BEFORE menu was opened.
## - Gamepad/controller keybinds in a second tab.

#region SCREEN MENU IMPLEMENTATION

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

#endregion

#region KEYBINDING MENU

static var instance: KeybindsMenu # Psuedo-singleton for quick access...
var is_rebinding := false # Are we currently rebinding something?

# Used to track change from not rebinding to rebinding and vice versa
var previously_was_rebinding := false 

func _ready() -> void:
	instance = self
	is_rebinding = false

func _process(delta: float) -> void:
	if is_rebinding:
		if not previously_was_rebinding:
			switch_on_rebinding_mode()
		previously_was_rebinding = true
	else:
		if previously_was_rebinding:
			switch_off_rebinding_mode()
		previously_was_rebinding = false

func switch_on_rebinding_mode() -> void:
	ScreenUI.keybinding_dimmer.show()
	%BackButton.disabled = true
	
	TweenUtil.pop_delta(%TabContainer, Vector2(0.15, 0.15), 0.2)

func switch_off_rebinding_mode() -> void:
	ScreenUI.keybinding_dimmer.hide()
	%BackButton.disabled = false
	
	TweenUtil.pop_delta(%TabContainer, Vector2(0.15, 0.15), 0.2)


func _on_back_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	ScreenUI.exit_menu()

#endregion

#region RESET TO DEFAULTS

func _on_reset_button_pressed() -> void:
	SfxManager.play_sound_effect("ui_click")
	#TweenUtil.pop_delta(%TabContainer, Vector2(0.15, 0.15), 0.2)
	await _prompt_for_reset()

## Generate confirmation of reset prompt... and link to callback
func _prompt_for_reset() -> void:
	ScreenUI.add_menu(ScreenUI.confirmation_menu)
	ScreenUI.confirmation_menu.set_message("Are you sure you want to reset all keybinds to defaults?")
	ScreenUI.confirmation_menu.set_accept_text("Yes, Reset")
	ScreenUI.confirmation_menu.set_decline_text("No, Keep Existing")
	ScreenUI.confirmation_menu.connect_choice_to(_on_reset_choice)
	await ScreenUI.confirmation_menu.choice_made

## Confirmation of reset prompt callback
func _on_reset_choice(choice: bool) -> void:
	if choice:
		# Get all individual KeybindLines
		for child in %KeybindContainer.get_children():
			if child is KeybindLine:
				child.reset_value()
				SfxManager.play_sound_effect("ui_pages")
		TweenUtil.pop_delta(%TabContainer, Vector2(0.15, 0.15), 0.2)
	else:
		SfxManager.play_sound_effect("ui_click")

#endregion
