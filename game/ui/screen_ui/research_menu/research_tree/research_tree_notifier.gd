class_name ResearchTreeNotifier
extends Node

var notif: Notification

func _process(delta: float) -> void:
	if ResearchTree.instance.get_num_tech_points() > 0:
		var msg := '[color=6be1e3][url="tech"]' + get_correct_plural_for_notif( ResearchTree.instance.get_num_tech_points()) + '[/url]'
		if not notif or notif.is_removed:
			notif = Notification.new(&"tech_points_available", msg, { "priority": 10 })
			NotificationLog.instance.add_notification(notif)
		else:
			notif.set_message(msg)
	else:
		remove_notif()

func get_correct_plural_for_notif(total: int) -> String:
	if total == 1:
		return tr(&"NOTIF_TECH_POINT_AVAILABLE").format({ "num": total })
	else:
		return tr(&"NOTIF_TECH_POINTS_AVAILABLE").format({ "num": total })

func remove_notif() -> void:
	if notif:
		notif.remove()

func _exit_tree() -> void:
	remove_notif()
