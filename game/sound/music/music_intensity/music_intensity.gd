class_name MusicIntensity

static var intensity: float = 0.0
static var target_intensity: float = 0.0

static var intensity_bonuses: Dictionary[StringName, float] = {}

const INCREASE_CONSTANT := 25.0
const DECREASE_CONSTANT := 20.0

static func set_target_intensity(value: float) -> void:
	#target_intensity = max(value, target_intensity)
	target_intensity = value

static func get_target_intensity() -> float:
	var add := 0.0
	for bonus: float in intensity_bonuses.values():
		add += bonus
	return target_intensity + add

static func jump_to_intensity(value: float) -> void:
	set_target_intensity(value)
	intensity = value

static func get_intensity() -> float:
	return intensity

static func update(delta: float) -> void:
	if get_target_intensity() > intensity:
		intensity = MathUtil.decay(intensity, get_target_intensity(), INCREASE_CONSTANT, delta)
	elif get_target_intensity() < intensity:
		intensity = MathUtil.decay(intensity, get_target_intensity(), DECREASE_CONSTANT, delta)
