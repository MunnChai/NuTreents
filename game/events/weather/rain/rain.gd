class_name Rain
extends Node2D

static var instance: Rain

func _ready() -> void:
	instance = self
	stop_particles()

func start_particles() -> void:
	$RainParticles.emitting = true
	$RainParticles2.emitting = true
	$Splashes.emitting = true

func stop_particles() -> void:
	$RainParticles.emitting = false
	$RainParticles2.emitting = false
	$Splashes.emitting = false
