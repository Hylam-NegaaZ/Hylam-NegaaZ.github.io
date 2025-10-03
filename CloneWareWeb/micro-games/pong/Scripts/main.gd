extends Node2D
class_name PongMatchController

signal microgame_finished(win: bool)

var microgame_description := "Score \na point!"
var description_font_size := 24

@export var use_ball : PackedScene
@export var player_paddle : CharacterBody2D
@export var cpu_paddle : CharacterBody2D

@export var paddles_padding : float

@onready var score_label : Label = $ColorRect/State_Score
var ball_instance : Node2D 

func _ready():
	AudioManager.play_music("Pong-background")
	difficuty_set()
	set_paddle_position(paddles_padding)
	spawn_ball()

func _process(delta: float) -> void:
	pass

func set_paddle_position(padding_ratio : float):
	var screen_size = get_viewport_rect().size
	var center_y = screen_size.y / 2
	var padding = screen_size.x * padding_ratio
	player_paddle.position = Vector2(padding, center_y)
	cpu_paddle.position = Vector2(screen_size.x - padding, center_y)

func spawn_ball():
	if !ball_instance:
		ball_instance = use_ball.instantiate()
		add_child(ball_instance)
		ball_instance.position = get_viewport_rect().get_center()
		$NewBallTimer.start()
	else:
		ball_instance.speed = ball_instance.INITIAL_SPEED
		ball_instance.queue_free()

func scored_ball():
	ball_instance.queue_free()
	$AudioManagement/SFX/ScoredSFX.play()

#signal checking
func _on_left_score_body_entered(_body: Node2D) -> void:
	scored_ball()
	score_label.text = "YOU LOSE!"
	finish_game(false)

func _on_right_score_body_entered(_body: Node2D) -> void:
	scored_ball()
	score_label.text = "YOU WIN!"
	finish_game(true)

func _on_new_ball_timer_timeout() -> void:
	ball_instance.new_ball();

func finish_game(win: bool):
	AudioManager.stop_music()
	
	await get_tree().create_timer(0.5).timeout
	emit_signal("microgame_finished", win)

func difficuty_set() -> void:
	cpu_paddle.speed = clamp(float(GameManager.stage_completed * 20), 150.0, 400.0)
