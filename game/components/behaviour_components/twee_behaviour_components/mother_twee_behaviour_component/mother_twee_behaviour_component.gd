class_name MotherTweeBehaviourComponent
extends TweeBehaviourComponent

func _ready():
	super._ready()
	
	health_component.health_subtracted.connect(take_damage)

# Override Twee "growing" functionality
func _process(delta: float) -> void:
	pass

func _on_death():
	die()

func die():
	Global.game_state = Global.GameState.GAME_OVER
	SceneLoader.transition_to_game_over()

var notification: Notification

func take_damage(damage: int) -> void:
	CameraShake.instance.add_trauma(0.1)
	
	## NOTIFY PLAYER
	if not notification or notification.is_removed:
		notification = Notification.new(&"mother_tree_attacked", '[color=ff5671][url="goto"]' + tr(&"NOTIF_MOTHER_TREE_ATTACKED") + '[/url]', { "priority": 10, "time_remaining": 3.0, "position": grid_position_component.get_average_pos()});
		NotificationLog.instance.add_notification(notification)
	else:
		notification.properties["time_remaining"] = 3.0
