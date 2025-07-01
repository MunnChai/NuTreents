extends CanvasLayer

# For fading
const BLACK_SCREEN = preload("res://scene_loader/black_screen.tscn")

# For loading scenes
const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn") # Main menu
const MAIN = preload("res://main.tscn") # Game scene
const GAME_OVER = preload("res://ui/game_over/game_over.tscn") # Gane over screen
const VICTORY_SCREEN = preload("res://ui/victory/victory_screen.tscn")
const TUTORIAL = preload("res://tutorial/tutorial.tscn")

# Fade in + out duration
const FADE_DURATION = 2.0

var black_screen: ColorRect
var is_transitioning: bool = false

signal scene_changed

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	black_screen = ScreenUI.black_screen

func transition_to_main_menu():
	transition_to_packed(MAIN_MENU)
	
	await scene_changed
	
	# --- Data Handling Fix ---
	# The session data is now cleared here, AFTER returning to the main menu.
	# This is the correct place to end a session.
	Global.session_data.clear()
	
	# Reset session id when returning to main menu
	Global.session_id = 0

func transition_to_game(session_data: Dictionary = {}):
	transition_to_packed(MAIN)
	
	# Pass session data to game
	await scene_changed
	
	Global.session_data = session_data

func transition_to_game_over():
	transition_to_packed(GAME_OVER, 2.0, 2.0)

func transition_to_victory_screen():
	transition_to_packed(VICTORY_SCREEN, 2.0, 2.0)

func transition_to_tutorial():
	transition_to_packed(TUTORIAL, 1.0, 1.0)

func transition_to_packed(scene: PackedScene, tween_in_duration = FADE_DURATION / 2, tween_out_duration = FADE_DURATION / 2):
	if (is_transitioning):
		return
	
	is_transitioning = true
	var tween_in = create_tween()
	
	GameCursor.instance.force_wait = true
	
	if FloatingTooltip.instance:
		FloatingTooltip.instance.force_hidden = true
	
	tween_in.tween_property(black_screen, "modulate:a", 1.0, tween_in_duration)
	
	tween_in.finished.connect(
		func():
			# --- BUG FIX ---
			# We now directly unpause the tree and remove the audio filter.
			# This is more robust than calling a global function during a scene transition.
			if get_tree().paused:
				get_tree().paused = false
			
			if AudioServer.get_bus_effect_count(AudioServer.get_bus_index("Music")) != 0:
				AudioServer.remove_bus_effect(AudioServer.get_bus_index("Music"), 0)

			ScreenUI.terminate_stack()
			
			var music: Node = get_tree().get_first_node_in_group("music")
			if (music):
				music.audio_stream_player.stop()
			
			get_tree().change_scene_to_packed(scene)
			
			var tween_out = create_tween()
			
			tween_out.tween_property(black_screen, "modulate:a", 0.0, tween_out_duration)
			is_transitioning = false
			
			GameCursor.instance.force_wait = false
			
			if FloatingTooltip.instance:
				FloatingTooltip.instance.force_hidden = false
			
			scene_changed.emit()
	)
	
	# --- Data Handling Fix ---
	# Global.session_data.clear() has been REMOVED from this function.
	# It was clearing the data too early, before the new scene could load it.
