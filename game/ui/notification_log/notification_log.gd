class_name NotificationLog
extends Node

## THE DATA COMPONENT OF THE NOTIFICATION LOG IN THE UI

## TODO: Notification coallation/stacking for close enough in time

signal notification_added(notif: Notification)
signal notification_expired(notif: Notification)
signal notification_removed(notif: Notification)

@export var notification_log_visual: Control
@export var notification_container: Control

var notifications: Array[Notification] = []

static var instance: NotificationLog

func _ready() -> void:
	instance = self
	
	notification_added.connect(_on_notification_added)

var is_visible := true

func _process(delta: float) -> void:
	for notif: Notification in notifications:
		notif.update(delta)
	
	if notifications.is_empty():
		if is_visible:
			TweenUtil.fade(notification_log_visual, 0.0, 0.5)
			is_visible = false
	else:
		if not is_visible:
			TweenUtil.fade(notification_log_visual, 1.0, 0.5)
			is_visible = true

func _on_notification_added(notif: Notification) -> void:
	create_new_notification(notif)
	notif.expired.connect(_on_notif_expired)
	notif.removed.connect(_on_notif_removed)

const NOTIFICATION_VISUAL = preload("./notification_visual/notification_visual.tscn")
func create_new_notification(notif: Notification) -> void:
	var new_notification := NOTIFICATION_VISUAL.instantiate()
	notification_container.add_child(new_notification)
	if notif.properties.get("priority", 0) >= 10:
		notification_container.move_child(new_notification, 0)
	new_notification.assign_notification(notif)

func _on_notif_expired(notif: Notification) -> void:
	notification_expired.emit(notif)

func _on_notif_removed(notif: Notification) -> void:
	notification_removed.emit(notif)
	notifications.erase(notif)

#region ADD/REMOVE

func add_notification(notif: Notification) -> void:
	notifications.append(notif)
	notification_added.emit(notif)

func remove_notification(notif: Notification) -> void:
	notif.remove()

#endregion
