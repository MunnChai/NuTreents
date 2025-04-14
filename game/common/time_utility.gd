class_name TimeUtil

## Implements various useful time-based components
## for use in other scripts.

## ---

## Produces unscaled delta time by dividing out the Engine time_scale modification
static func unscaled_delta(delta: float) -> float:
	return delta / Engine.time_scale
