extends Node2D

var microgame_description := "Fly through\n the pipes!"
var description_font_size := 24

signal microgame_finished(win: bool)

@export var pipe_scene : PackedScene

var game_started : bool

var game_running : bool
var game_over : bool
var scroll
var score
var scroll_speed : float = 5
var screen_size : Vector2i
var ground_height : int
var pipes : Array
var pipes_amount : int = 2
var score_needed : int = pipes_amount
const PIPE_DELAY : int = 300
const PIPE_RANGE : int = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	AudioManager.play_music("FlappyBird-background")
	
	difficuty_set()
	screen_size = get_viewport_rect().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()
	await get_tree().create_timer(2).timeout
	if !game_running:
		start_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0 
	
	$ScoreLabel.text = "Let's go!" 
	
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipes()
	
	$Player.reset()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed and $Player.is_gliding == false):
				$SFX/Jump.play()
				if game_running == false and game_started == false:
					start_game()
				else:
					if $Player.flying:
						$Player.flap()
						check_top()
			elif (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
				if $Player.flying: 
					$Player.glide()

func start_game():
	game_started = true
	game_running = true
	$Player.flying = true
	$Player.flap()
	
	$PipeTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		scroll += scroll_speed
		if scroll >= screen_size.x:
			scroll = 0
		
		$Ground.position.x = -scroll 
		
		for pipe in pipes:
			pipe.position.x -= scroll_speed

func _on_pipe_timer_timeout():
	generate_pipes()

func generate_pipes():
	if (pipes_amount > 0):
		pipes_amount -= 1
		
		var pipe = pipe_scene.instantiate()
		pipe.position.x = screen_size.x + PIPE_DELAY
		pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
		pipe.hit.connect(bird_hit)
		pipe.scored.connect(scored)
		add_child(pipe)
		pipes.append(pipe)

func scored():
	score += 1
	$SFX/Score.play()
	
	if (score >= score_needed):
		AudioManager.play_sfx("FlappyBird-success")
		finish_game(true)


func check_top():
	if $Player.position.y < 0:
		$Player.falling = true
		stop_game()

func stop_game():
	$SFX/Lose.play()
	
	$PipeTimer.stop()
	$Player.flying = false
	game_running = false
	game_over = true
	
	finish_game(false)

func bird_hit():
	$Player.falling = true
	if (game_running and game_over == false): stop_game()

func _on_ground_hit() -> void:
	$Player.falling = false
	if (game_running and game_over == false): stop_game()

func play_tween(tween_obj):
	var sprite = tween_obj
	var tween = create_tween().set_loops(1) # 0 = no auto loop
	 # Squash down
	tween.tween_property(
		sprite, "scale", Vector2(1.2, 0.8), 0.15
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Stretch up
	tween.tween_property(
		sprite, "scale", Vector2(0.9, 1.3), 0.15
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Return to normal
	tween.tween_property(
		sprite, "scale", Vector2.ONE, 0.2
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func finish_game(win: bool):
	AudioManager.stop_music()
	
	if win:
		$ScoreLabel.text = "Great job!"
		play_tween($ScoreLabel)
	else:
		$ScoreLabel.text = "Oh no!"
		play_tween($ScoreLabel)
	
	await get_tree().create_timer(0.5).timeout
	emit_signal("microgame_finished", win)
	
	$PipeTimer.stop()
	$Player.flying = false
	game_running = false
	game_over = true

func difficuty_set() -> void:
	pipes_amount = clamp(1 + int(GameManager.stage_completed / 3), 2, 6) 
	scroll_speed = clamp(1 + int(GameManager.stage_completed / 5), 3, 7)
	score_needed = pipes_amount
