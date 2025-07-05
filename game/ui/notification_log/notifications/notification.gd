class_name Notification
extends RefCounted

## A NOTIFICATION TO BE REGISTERED IN THE NOTIFICATION LOG

signal expired(notif: Notification)
signal removed(notif: Notification)

const TIME_REMAINING := "time_remaining"

var type: StringName
var message: String
var properties: Dictionary

var hover_func: Callable
var click_func: Callable

var is_removed: bool = false

func _init(_type: StringName, _message: String, _properties: Dictionary, _on_hover: Callable = func (): pass, _on_click: Callable = func (): pass):
	type = _type
	message = _message
	properties = _properties
	
	hover_func = _on_hover
	click_func = _on_click
	
	expired.connect(_on_expired)
	removed.connect(_on_removed)

func _on_expired(notif: Notification) -> void:
	remove()

func _on_removed(notif: Notification) -> void:
	pass

## Call to signal that this notification should be removed
func remove() -> void:
	if not is_removed:
		removed.emit(self)
		is_removed = true

## Process time-based details of this notification
func update(delta: float) -> void:
	if is_removed:
		return
	
	if properties.has(TIME_REMAINING):
		properties[TIME_REMAINING] -= delta
		if properties[TIME_REMAINING] <= 0.0:
			expired.emit(self)

func click() -> void:
	if click_func:
		click_func.call()

func hover() -> void:
	if hover_func:
		hover_func.call()
