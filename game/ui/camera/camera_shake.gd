class_name CameraShake 
extends Node

static var instance: CameraShake

@export var decay = 0.5  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(64, 64)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.5  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

@onready var noise = FastNoiseLite.new()
var noise_y = 0

var back_kick = Vector2.ZERO

var final_offset = Vector2.ZERO
var final_rotation = 0

var camera_position = Vector2.ZERO

func _ready():
	instance = self
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func kick(amount):
	back_kick += amount

## TODO: Make shake NOT jank.

func _process(delta):
	pass
	#final_offset = Vector2.ZERO
	#trauma = max(0, trauma - delta * decay)
	#noise_y += delta * 100.0
	#
	#print(noise_y)
	#final_offset.x = max_offset.x * trauma * noise.get_noise_2d(noise.seed + 105.5, noise_y)
	#final_offset.y = max_offset.y * trauma * noise.get_noise_2d(noise.seed + 203.75, noise_y)
	#final_rotation = max_roll * trauma * noise.get_noise_2d(noise.seed, noise_y)
#
	#print(final_offset)
	#trauma = max(trauma - decay * delta, 0)
	#shake(delta)
	#back_kick = back_kick.lerp(Vector2.ZERO, delta * 2.0)
	#final_offset += back_kick

func shake(delta):
	var amount = pow(trauma, trauma_power)
	noise_y += 5 * delta
	final_rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	final_offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed + 105.5, noise_y)
	final_offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed + 203.75, noise_y)
