extends Node

@export var play_tutorial := false
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var day_player: AudioStreamPlayer = %DayPlayer

var clock: Clock

const CITY_LEAVES = preload("res://sound/music/City Leaves.mp3")

func _ready() -> void:
	clock = get_tree().root.find_child("Clock", true, false)
	if play_tutorial:
		audio_stream_player.stream = CITY_LEAVES
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	#audio_stream_player.play()
	audio_stream_player.bus = "Music"
	day_player.bus = "Music"
	
	#day_player.play()


enum Vibe {
	SMALL_FOREST,
	MEDIUM_FOREST,
	LARGE_FOREST,
	CALM_NIGHT,
	MILD_NIGHT,
	INTENSE_NIGHT,
	SILENCE
}

var current_vibe = Vibe.CALM_NIGHT
var playing_day := false
var has_transitioned := false

func _process(delta: float) -> void: 
	if not play_tutorial:
		if clock.get_curr_day_sec() > clock.HALF_DAY_SECONDS:
			## NIGHT
			if playing_day:
				playing_day = false
				transition_to_night()
			update_night_track()
			has_transitioned = false
		elif clock.get_curr_day_sec() > clock.HALF_DAY_SECONDS * AmbientLighting.PERCENT_EVENING_THRESHOLD:
			## EVENING
			if not has_transitioned:
				fade_all_out()
				has_transitioned = true
		elif clock.get_curr_day_sec() > clock.HALF_DAY_SECONDS * AmbientLighting.PERCENT_MORNING_THRESHOLD:
			## DAY
			if not playing_day:
				playing_day = true
				transition_to_day()
			update_day_track()
			has_transitioned = false
		else:
			## MORNING
			if not has_transitioned:
				fade_all_out()
				has_transitioned = true
	else:
		fade_all_out()

func fade_all_out():
	get_tree().create_tween().tween_property(audio_stream_player, "volume_linear", 0, 3.0);
	get_tree().create_tween().tween_property(day_player, "volume_linear", 0, 3.0);
	await get_tree().create_timer(3.0).timeout
	audio_stream_player.stream_paused = true
	day_player.stream_paused = true

func transition_to_day():
	day_player.stream_paused = false
	if not day_player.playing:
		day_player.play()
		day_player.volume_linear = 1.0
	else:
		get_tree().create_tween().tween_property(day_player, "volume_linear", 1, 2.0);

func transition_to_night():
	audio_stream_player.stream_paused = false
	if not audio_stream_player.playing:
		audio_stream_player.play()
	get_tree().create_tween().tween_property(audio_stream_player, "volume_linear", 1, 2.0);

func update_day_track() -> void:
	pass

func update_night_track() -> void:
	if not audio_stream_player.playing or audio_stream_player.stream_paused:
		return
	
	if audio_stream_player.get_stream_playback() == null:
		return
	
	if get_tree().get_nodes_in_group("enemies").size() >= 5:
		if current_vibe != Vibe.INTENSE_NIGHT:
			audio_stream_player.get_stream_playback().switch_to_clip_by_name("intense")
			current_vibe = Vibe.INTENSE_NIGHT
		# audio_stream_player["parameters/switch_to_clip"] = "intense"
	elif get_tree().get_nodes_in_group("enemies").size() >= 1:
		print("MILD")
		if current_vibe != Vibe.MILD_NIGHT:
			audio_stream_player.get_stream_playback().switch_to_clip_by_name("mild")
			current_vibe = Vibe.MILD_NIGHT
			# audio_stream_player["parameters/switch_to_clip"] = "mild"
	else:
		print("CALM")
		if current_vibe != Vibe.CALM_NIGHT:
			audio_stream_player.get_stream_playback().switch_to_clip_by_name("calm")
			current_vibe = Vibe.CALM_NIGHT
