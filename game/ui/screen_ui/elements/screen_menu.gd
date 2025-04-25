class_name ScreenMenu
extends Control

## SCREEN MENU
## Abstract base class for all menus in ScreenUI

var id: String = "screen_menu"

func _ready() -> void:
	modulate.a = 0
	## REMEMBER TO FADE IN ON OPEN!

## OVERRIDE THIS WITH DESIRED BEHAVIOUR
## Called when this menu is freshly opened
## Previous menu is the menu that was previously highest on the stack
func open(previous_menu: ScreenMenu) -> void:
	show()

## OVERRIDE THIS WITH DESIRED BEHAVIOUR
## Called when this menu is closed
## Next menu is the menu that will become the highest on the stack
func close(next_menu: ScreenMenu) -> void:
	hide()

## OVERRIDE THIS WITH DESIRED BEHAVIOUR
## Called when this menu is "re-focused" after another menu was closed
## Previous menu is the menu that was previously highest before being closed
func return_to(previous_menu: ScreenMenu) -> void:
	pass
