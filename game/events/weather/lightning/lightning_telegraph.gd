class_name LightningTelegraph
extends Node2D

const LIGHTNING_TELEGRAPH_TIME := 5.0

signal telegraph_ended

func _ready() -> void:
	$Timer.start(LIGHTNING_TELEGRAPH_TIME)
	spark_gap = 1.2
	
	SoundManager.play_oneshot(&"lightning_spark", global_position)

var spark_gap := 0.0

func _process(delta: float) -> void:
	spark_gap -= delta
	if spark_gap < 0.0:
		spark_gap = 1.2
		$Sparks.restart()
		SoundManager.play_oneshot(&"lightning_spark", global_position)

func _on_timer_timeout() -> void:
	telegraph_ended.emit()
	SoundManager.play_oneshot(&"lightning_spark", global_position)
	queue_free()
