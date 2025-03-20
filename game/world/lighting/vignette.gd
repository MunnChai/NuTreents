extends ColorRect

const MAX_VIGNETTE = 0.75
const MIN_VIGNETTE = 0.3

func _process(delta: float) -> void:
	get_material().set_shader_parameter("alpha", MIN_VIGNETTE + AmbientLighting.amount_of_night * (MAX_VIGNETTE - MIN_VIGNETTE))
