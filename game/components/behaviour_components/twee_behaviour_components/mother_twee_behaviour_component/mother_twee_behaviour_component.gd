class_name MotherTweeBehaviourComponent
extends TweeBehaviourComponent

func _ready():
	super._ready()
	
	# --- BUG FIX ---
	# Changed the signal connection from the old "health_subtracted" to the
	# new, more descriptive "damaged" signal in the HealthComponent.
	health_component.damaged.connect(take_damage)

# Override Twee "growing" functionality
func _process(delta: float) -> void:
	pass

func _on_death():
	die()

func die():
	Global.game_state = Global.GameState.GAME_OVER
	SceneLoader.transition_to_game_over()

var notification: Notification

# --- BUG FIX ---
# Updated the function signature to match the parameters of the "damaged" signal.
# The unused parameters are prefixed with an underscore to prevent warnings.
func take_damage(_amount: float, _source: Node, _owner: Node2D) -> void:
	CameraShake.instance.add_trauma(0.1)
	
	## NOTIFY PLAYER
	if not notification or notification.is_removed:
		notification = Notification.new(&"mother_tree_attacked", '[color=ff5671][url="goto"]' + tr(&"NOTIF_MOTHER_TREE_ATTACKED") + '[/url]', { "priority": 10, "time_remaining": 3.0, "position": grid_position_component.get_average_pos()});
		NotificationLog.instance.add_notification(notification)
	else:
		notification.properties["time_remaining"] = 3.0
