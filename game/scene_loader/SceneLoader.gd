extends CanvasLayer

# For fading
const BLACK_SCREEN = preload("res://scene_loader/black_screen.tscn")

# For loading scenes
const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn") # Main menu
const MAIN = preload("res://main.tscn") # Game scene
const GAME_OVER = preload("res://ui/game_over/game_over.tscn") # Gane over screen
const VICTORY_SCREEN = preload("res://ui/VictoryScreen.tscn")
# Fade in + out duration
const FADE_DURATION = 2.0

var black_screen: ColorRect
var is_transitioning: bool = false

func _ready():
	black_screen = BLACK_SCREEN.instantiate()
	black_screen.z_index = 100
	layer = 100
	
	add_child(black_screen)

func transition_to_main_menu():
	transition_to_packed(MAIN_MENU)

func transition_to_game():
	transition_to_packed(MAIN)

func transition_to_game_over():
	transition_to_packed(GAME_OVER, 2.0, 2.0)

func transition_to_victory_screen():
	transition_to_packed(VICTORY_SCREEN, 2.0, 2.0)

func transition_to_packed(scene: PackedScene, tween_in_duration = FADE_DURATION / 2, tween_out_duration = FADE_DURATION / 2):
	if (is_transitioning):
		return
	
	
	
	is_transitioning = true
	var tween_in = get_tree().create_tween()
	
	tween_in.tween_property(black_screen, "modulate:a", 1.0, tween_in_duration)
	
	
	tween_in.finished.connect(
		func():
			var music: Node = get_tree().get_first_node_in_group("music")
			if (music):
				print("STOPPING_MUSIC")
				music.audio_stream_player.stop()
			
			get_tree().change_scene_to_packed(scene)
			
			var tween_out = get_tree().create_tween()
			
			tween_out.tween_property(black_screen, "modulate:a", 0.0, tween_out_duration)
			is_transitioning = false
	)
