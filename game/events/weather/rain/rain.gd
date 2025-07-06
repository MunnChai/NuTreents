class_name Rain
extends Node2D

static var instance: Rain

@onready var rain_particles: GPUParticles2D = $RainParticles
@onready var rain_particles_2: GPUParticles2D = $RainParticles2
@onready var splashes: GPUParticles2D = $Splashes

const FADE_DURATION = 1.5

func _ready() -> void:
	instance = self
	# Ensure particles are off and invisible at the start.
	rain_particles.emitting = false
	rain_particles_2.emitting = false
	splashes.emitting = false
	self.modulate.a = 0.0

func start_particles() -> void:
	# --- BUG FIX ---
	# Calling restart() clears all existing particles before starting emission.
	# This prevents the "splattering" effect when the camera moves while the
	# particles were previously disabled but still technically "alive".
	rain_particles.restart()
	rain_particles_2.restart()
	splashes.restart()
	
	# --- VIBE ENHANCEMENT ---
	# Instead of instantly appearing, the rain now smoothly fades in.
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func stop_particles() -> void:
	# --- VIBE ENHANCEMENT ---
	# The rain now smoothly fades out instead of abruptly stopping.
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	
	# We wait for the fade to complete before turning off the emitters.
	await tween.finished
	
	# This check ensures that if the rain was started again while it was
	# fading out, we don't accidentally turn it off.
	if self.modulate.a < 0.1:
		rain_particles.emitting = false
		rain_particles_2.emitting = false
		splashes.emitting = false
