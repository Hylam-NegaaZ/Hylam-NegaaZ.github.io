extends Node2D

signal gamestage_finished

var game_over : bool = true
var mode_index : int = 0
var microgame = GameManager.loadMicrogame(mode_index)

@onready var container := $Games
@onready var ui_heart_container := $GUI/TransitionPanel/UIHeartContainer
@onready var transition := $GUI/Transition
@onready var transition_label := $GUI/TransitionPanel/Background/TransitionLabel

@onready var ui_particles := $GUI/TransitionPanel/CPUParticles2D

func _ready():
	if game_over:
		game_over = false
		GameManager.gameStart()
		load_ui_heart(GameManager.lives)
		await play_transition("in", 0)
		await play_transition("ready", 3)
		await load_microgame()
		await play_transition("out", 2)

func load_microgame():
	for c in container.get_children():
		c.queue_free()
	microgame = GameManager.loadMicrogame(mode_index)
	container.add_child(microgame)
	await play_transition("game_desc", 0.75)
	
	# Listen for result signal from microgame
	microgame.connect("microgame_finished", Callable(self, "_on_microgame_finished"))

func load_ui_heart(heart_amount):
	if !game_over:
		#check if there is still hearts left, clear it
		for c in ui_heart_container.get_children():
			c.queue_free()
		if (heart_amount > 0):
			for i in heart_amount:
				ui_heart_container.add_child(load("res://Scenes/ui_heart.tscn").instantiate())
	else:
		for c in ui_heart_container.get_children():
			c.queue_free()

func load_result(is_winning: bool):
	#hardcoded_cause_lazy
	var results_text = $GUI/ResultsPanel/ResultPanel/VBoxContainer
	var stage_completed = $GUI/ResultsPanel/ResultPanel/VBoxContainer/StageCompleted
	var lifes_left = $GUI/ResultsPanel/ResultPanel/VBoxContainer/LifesLeft
	var bonus = $GUI/ResultsPanel/ResultPanel/VBoxContainer/Bonus
	var final_result = $GUI/ResultsPanel/ResultPanel/VBoxContainer/FinalResults
	var rank = $GUI/ResultsPanel/ResultPanel/VBoxContainer/Rank
	var button = $GUI/ResultsPanel/ResultPanel/VBoxContainer/Button
	
	button.visible = false
	for c in results_text.get_children():
		for d in c.get_children():
			d.visible = false
	#show first
	results_text.get_child(0).visible = true
	final_result.get_child(0).visible = true
	final_result.get_child(1).visible = true
	rank.get_child(0).visible = true
	
	final_result.get_child(1).text = "0"
	
	#StageCompleted
	await get_tree().create_timer(1).timeout
	AudioManager.play_sfx("SFX_Main-transition")
	stage_completed.get_child(0).visible = true
	await get_tree().create_timer(1).timeout
	stage_completed.get_child(1).visible = true
	count_to(stage_completed.get_child(1), 0, GameManager.stage_completed)
	
	final_result.get_child(1).label_settings.font_size = 16
	final_result.get_child(1).text = str(GameManager.stage_completed) + " x "
	
	#LifesLeft
	if is_winning:
		await get_tree().create_timer(1).timeout
		AudioManager.play_sfx("SFX_Main-transition")
		lifes_left.get_child(0).visible = true
		await get_tree().create_timer(1).timeout
		lifes_left.get_child(1).visible = true
		count_to(lifes_left.get_child(1), 0, GameManager.lives)
		final_result.get_child(1).text = str(GameManager.stage_completed) + " x " + str(GameManager.lives) + " + "
	else:
		lifes_left.visible = false
		final_result.get_child(1).text = str(GameManager.stage_completed) + " x 1 " + " + "
	#bonus
	await get_tree().create_timer(1).timeout
	bonus.get_child(0).visible = true
	await get_tree().create_timer(1).timeout
	bonus.get_child(1).visible = true
	count_to(bonus.get_child(1), 0, 1000)
	
	if is_winning:
		final_result.get_child(1).text = str(GameManager.stage_completed) + " x " + str(GameManager.lives) + " + 1000" 
	else:
		final_result.get_child(1).text = str(GameManager.stage_completed) + " x 1" + " + 1000" 
	
	#FinalResults + Rank
	await get_tree().create_timer(2).timeout
	AudioManager.play_sfx("SFX_Main-transition")
	final_result.get_child(1).label_settings.font_size = 32
	count_to(final_result.get_child(1), 0, GameManager.calc_score())
	await get_tree().create_timer(1).timeout
	AudioManager.play_sfx("SFX_Microgame-uiConfirm")
	rank.get_child(1).visible = true
	rank.get_child(1).text = "A"
	await get_tree().create_timer(1).timeout
	button.visible = true

func _on_microgame_finished(win: bool):
	if win:
		GameManager.stage_completed += 1
		if (GameManager.stage_completed < GameManager.stage_needed):
			await play_transition("in",1)
			await play_transition("winning",3)
			await play_transition("ready", 2.5)
			await load_microgame()
			await play_transition("out",2)
		else:
			game_over = true
			load_ui_heart(GameManager.lives)
			await play_transition("in",1)
			await play_transition("winning_finale",4)
			await play_transition("results_in",0)
			load_result(win)
	elif !win:
		GameManager.lose_life()
		await play_transition("in",1)
		await play_transition("losing",3)
		if GameManager.lives > 0:
			await play_transition("ready", 2.5)
			await load_microgame()
			await play_transition("out",2)
		else:
			game_over = true
			await play_transition("results_in",0)
			load_result(win)
	load_ui_heart(GameManager.lives)
	print(str(GameManager.stage_completed))

func play_transition(transition_type, wait_time):
	if microgame:
		match transition_type:
			1, "in":
				AudioManager.play_sfx("SFX_Main-transition")
				if (GameManager.stage_completed > 0) and !game_over:
					$GUI/TransitionPanel/GamePassedLabel.text = "Games passed:" + str(GameManager.stage_completed)
				elif (GameManager.stage_completed <= 0) or game_over:
					$GUI/TransitionPanel/GamePassedLabel.text = ""
				transition.play("Ready_in")
			2, "out":
				AudioManager.play_sfx("SFX_Main-transition")
				transition.play("Ready_out")
			3, "ready":
				AudioManager.play_music("Microgame-ready")
				transition_label.label_settings.font_size = 32
				transition_label.text = "Ready!"
				play_tween(transition_label)
			4, "game_desc":
				transition_label.label_settings.font_size = microgame.description_font_size
				transition_label.text = microgame.microgame_description
				play_tween(transition_label)
			5, "losing":
				AudioManager.play_music("Microgame-lose")
				transition_label.label_settings.font_size = 32
				var stage_left = (GameManager.stage_needed - GameManager.stage_completed)
				match stage_left:
					1:
						transition_label.text = "The end\nis near!"
					2, 3:
						transition_label.text = "Almost\nthere!"
					_: transition_label.text = "Oh no!"
				play_tween(transition_label)
				ui_heart_container.get_children().back().heart_break()
			6, "winning":
				AudioManager.play_music("Microgame-win")
				transition_label.label_settings.font_size = 32
				transition_label.text = "Nice job!"
				play_tween(transition_label)
				play_particles(400,0.9,true)
			7, "results_in":
				$GUI/TransitionPanel/GamePassedLabel.text = ""
				transition_label.visible = false
				transition.play("results_in")
			8, "winning_finale":
				AudioManager.play_music("Microgame-stageClear")
				transition_label.label_settings.font_size = 24
				transition_label.text = "Stage\nCompleted!"
				play_tween(transition_label)
				play_particles(400,0.9,false)
			_: pass
	#No modes selected
	else:
		pass
	await get_parent().get_tree().create_timer(wait_time).timeout

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

func play_particles(amount, explosive_amount, is_oneshot:bool):
	ui_particles.amount = amount
	ui_particles.explosiveness = explosive_amount
	ui_particles.one_shot = is_oneshot
	ui_particles.emitting = true

func count_to(label: Label, from: int, to: int, duration: float = 1.0):
	var tween = create_tween()
	tween.EASE_OUT
	tween.tween_method(
		func(value):
			label.text = str(round(value)),
		from,
		to,
		duration
	)

#signals
func _on_button_pressed() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx("SFX_Main-uiConfirm")
	emit_signal("gamestage_finished")
