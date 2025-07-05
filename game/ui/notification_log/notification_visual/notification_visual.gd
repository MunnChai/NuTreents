class_name NotificationVisual
extends RichTextLabel

var notification: Notification

func _ready() -> void:
	text = ""

func assign_notification(notif: Notification) -> void:
	notification = notif
	text = notif.message
	
	notif.removed.connect(_on_remove)

func _on_remove(notif: Notification) -> void:
	queue_free()

func _on_meta_clicked(meta: Variant) -> void:
	print(meta)
