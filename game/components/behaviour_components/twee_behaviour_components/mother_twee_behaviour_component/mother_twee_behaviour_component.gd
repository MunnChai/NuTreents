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

func take_damage(damage: int) -> void:
	CameraShake.instance.add_trauma(0.1)
