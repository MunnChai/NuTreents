class_name FireNotifierComponent
extends Node

## Notifies the player with a fire warning if the fire component is ignited
## With a shortcut to camera move over to the fire

@export var flammable: FlammableComponent
@export var grid_pos: GridPositionComponent

var notification: Notification

func _ready() -> void:
	if flammable:
		flammable.ignited.connect(_on_ignited)
		flammable.burned_out.connect(_on_ended)
		flammable.extinguished.connect(_on_ended)

func _on_ignited(fire: Fire) -> void:
	notification = Notification.new(&"fire", "FIRE! A tree in your forest is on fire. [url=\"goto\"]GO TO TREE[/url]", { "position": grid_pos.get_pos() });
	NotificationLog.instance.add_notification(notification)

func _on_ended() -> void:
	if notification:
		notification.remove()

func _exit_tree() -> void:
	if notification:
		notification.remove()
