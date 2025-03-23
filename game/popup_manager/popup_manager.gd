extends Node 

const FONT = preload("res://ui/fonts/monogram/monogram.ttf")

const POPUP = preload("res://popup_manager/popup.tscn")

const SIZE_MULTIPLIER: float = 0.15
const MIN_SIZE: float = 1.0
const TWEEN_DURATION: float = 1.0
const Y_OFFSET_RANGE: float = 20

func create_popup(text: String, position: Vector2, text_color: Vector3 = Vector3(1, 1, 1)):  
	var popup = POPUP.instantiate()
	popup.text = text
	popup.z_index = 200
	popup.position += position
	
	call_deferred("add_child", popup)
 
	popup.pivot_offset = Vector2(popup.size / 2)
	
	var alpha_tween = get_tree().create_tween()
	alpha_tween.set_ease(Tween.EASE_IN_OUT)
	alpha_tween.set_trans(Tween.TRANS_CUBIC)
	alpha_tween.set_parallel(true) 
	alpha_tween.tween_property(popup, "modulate:a", 0.0, TWEEN_DURATION)
	
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_OUT)
	#tween.set_trans(Tween.TRANS_EXPO)
	#tween.set_parallel(true)
	#tween.tween_property(popup, "position:y", popup.position.y - Y_OFFSET_RANGE, TWEEN_DURATION)
	#
	alpha_tween.finished.connect(
		func():
			popup.queue_free()
	) 
