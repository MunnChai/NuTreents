extends PointLight2D

@export var total_energy := 0.5

func _process(delta: float) -> void:
	# Only turn on at night
	energy = AmbientLighting.amount_of_night * total_energy
