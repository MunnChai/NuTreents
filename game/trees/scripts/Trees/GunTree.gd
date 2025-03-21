class_name GunTree
extends Twee

var damage: int = 3
var attack_range: int = 3

func _process(delta: float) -> void:
	life_time_seconds += delta
	
	if life_time_seconds > TIME_TO_GROW:
		if not is_large:
			upgrade_tree()
	
	
