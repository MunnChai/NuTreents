class_name Rain
extends Node2D

static var instance: Rain

@onready var rain_particles: GPUParticles2D = $RainParticles
@onready var rain_particles_2: GPUParticles2D = $RainParticles2
@onready var splashes: GPUParticles2D = $Splashes

const FADE_DURATION = 1.5
var _fade_tween: Tween # A reference to the currently active fade tween

func _ready() -> void:
	instance = self
	# Ensure particles are off and invisible at the start.
	rain_particles.emitting = false
	rain_particles_2.emitting = false
	splashes.emitting = false
	self.modulate.a = 0.0

func start_particles() -> void:
	# Kill any existing fade tween before starting a new one.
	# This prevents animations from fighting with each other.
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	# Set emitting to true immediately
	rain_particles.emitting = true
	rain_particles_2.emitting = true
	splashes.emitting = true
	
	rain_particles.restart()
	rain_particles_2.restart()
	splashes.restart()
	
	# Create a new tween to fade in.
	_fade_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func stop_particles() -> void:
	# Kill any existing fade tween.
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()

	# Create a new tween to fade out.
	_fade_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	
	# We wait for the fade to complete before turning off the emitters.
	await _fade_tween.finished
	
	# This check ensures that if the rain was started again while it was
	# fading out, we don't accidentally turn it off.
	if self.modulate.a < 0.1:
		rain_particles.emitting = false
		rain_particles_2.emitting = false
		splashes.emitting = false
