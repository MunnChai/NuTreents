class_name NotificationVisual
extends RichTextLabel

var notification: Notification

func _ready() -> void:
	text = ""

func assign_notification(notif: Notification) -> void:
	notification = notif
	if notif.properties.get("priority", 0) > 5:
		text = notif.message
	else:
		text = notif.message
	
	notif.removed.connect(_on_remove)
	notif.message_changed.connect(_on_message_change)
	
	modulate.a = 0.0
	TweenUtil.fade(self, 1.0, 0.5)

func _on_remove(notif: Notification) -> void:
	var tween := TweenUtil.fade(self, 0.0, 0.5)
	await tween.finished
	queue_free()

func _on_message_change(old_message: String, new_message: String) -> void:
	## Maybe do a change update? Juice?
	text = new_message

func _on_meta_clicked(meta: Variant) -> void:
	SoundManager.play_global_oneshot(&"ui_click")
	match meta:
		"goto":
			Camera.instance.core_position = Global.terrain_map.map_to_local(notification.properties.get("position"))
		"tech":
			ScreenUI.add_menu(ScreenUI.research_menu)
