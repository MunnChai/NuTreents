class_name SplashScreen
extends Node2D

## SPLASH SCREEN
## - Loads upon startup
## - Plays splash animation...
## - Upon any key input, skips ahead through animation to transition to main menu
## - Call SFX manager for any SFX so that player preferences are respected

@onready var timer: Timer = %Timer

var allow_skip := false # Can still use DEBUG BUTTON to skip immediately, though!
var already_skipping := false

var elapsed_time := 0.0

const ALLOW_SKIP_TIME := 0.5
const END_TIME := 5.0

func _ready() -> void:
	%FadeIn.modulate.a = 1.0
	TweenUtil.fade(%FadeIn, 0.0, 1.0)
	intro_sequence()

@onready var tree_icon_start_pos: Vector2 = %TreeIcon.position
@onready var wordmark_start_pos: Vector2 = %Wordmark.position

func intro_sequence() -> void:
	## START!... With nothing. Initalize...
	%TreeIcon.modulate.a = 0
	%Wordmark.modulate.a = 0
	%GodotIcon.modulate.a = 0
	%TreeIcon.position += Vector2.DOWN * 64.0
	%Wordmark.position += Vector2.DOWN * 64.0
	
	## START PROCEDURE
	timer.start(1.0)
	await timer.timeout
	
	timer.start(0.25)
	await timer.timeout
	SfxManager.play_sound_effect("splash_wind", false)

	timer.start(0.25)
	await timer.timeout
	
	allow_skip = true
	TweenUtil.pop_delta(%TreeIcon, Vector2(0.5, 0.5), 0.2)
	TweenUtil.fade(%TreeIcon, 1.0, 0.15)
	TweenUtil.whoosh(%TreeIcon, tree_icon_start_pos, 0.01)
	
	timer.start(0.5)
	await timer.timeout
	
	TweenUtil.pop_delta(%Wordmark, Vector2(0.5, 0.5), 0.2)
	TweenUtil.fade(%Wordmark, 1.0, 0.15)
	TweenUtil.whoosh(%Wordmark, wordmark_start_pos, 0.01)
	
	TweenUtil.whoosh(%SIInteractiveLogo, %SIInteractiveLogo.position + Vector2.UP * 10.0, 3.0)
	
	timer.start(2.5)
	await timer.timeout
	
	#TweenUtil.whoosh(%TreeIcon, tree_icon_start_pos + Vector2.DOWN * 64.0, 0.3)
	TweenUtil.fade(%TreeIcon, 0.0, 0.15)
	TweenUtil.fade(%Wordmark, 0.0, 0.15)
	
	timer.start(0.5)
	await timer.timeout
	
	TweenUtil.whoosh(%GodotIcon, %GodotIcon.position + Vector2.UP * 10.0, 3.0)
	
	TweenUtil.pop_delta(%GodotIcon, Vector2(0.5, 0.5), 0.2)
	TweenUtil.fade(%GodotIcon, 1.0, 0.15)
	
	timer.start(2.5)
	await timer.timeout
	
	TweenUtil.fade(%GodotIcon, 0.0, 0.15)
	
	timer.start(0.5)
	await timer.timeout
	
	skip_to_main_menu(false)
func _process(delta: float) -> void:
	if allow_skip:
		%SkipLabel.show()
	else:
		if not already_skipping:
			%SkipLabel.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if allow_skip or Input.is_action_just_pressed("debug_button"):
			skip_to_main_menu(true)

func skip_to_main_menu(play_sound: bool = false):
	if already_skipping:
		return
	already_skipping = true
	allow_skip = false
	if play_sound:
		SoundManager.play_global_oneshot(&"ui_click")
	
	#TweenUtil.fade(%TreeIcon, 0.0, 0.15)
	#TweenUtil.fade(%Wordmark, 0.0, 0.15)
	#TweenUtil.fade(%GodotIcon, 0.0, 0.15)
	TweenUtil.fade(%SkipLabel, 0.0, 0.15)
	
	SceneLoader.transition_to_main_menu()
