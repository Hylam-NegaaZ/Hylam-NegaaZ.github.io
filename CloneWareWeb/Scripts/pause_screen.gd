extends CanvasLayer

@onready var gameloader := $"../GameLoadScreen"
@onready var pause_screen := $PauseScreenFull
@onready var pause_button := $PauseBtn
@onready var continue_button := $PauseScreenFull/BtnContinue
@onready var restart_button := $PauseScreenFull/BtnRestart
@onready var quit_button := $PauseScreenFull/BtnQuit
@onready var pause_label := $PauseScreenFull/ColorRect/Label

var is_paused : bool = false

func _process(delta: float) -> void:
	if !(gameloader.get_children()) or is_paused:
		pause_button.hide()
	elif (gameloader.get_children()):
		pause_button.show()
	
	
func _ready() -> void:
	play_subtle_flow(continue_button)
	play_subtle_flow(restart_button)
	play_subtle_flow(quit_button)

func _input(event):
	if event.is_action_pressed("ui_cancel"): # usually Escape
		game_pause()

func game_pause():
	if !is_paused:
		continue_button.disabled = false
		restart_button.disabled = false
		quit_button.disabled = false
		
		get_tree().paused = true
		pause_label.text = "- PAUSED -"
		pause_screen.show()
		$PauseAnimation.play("pause_in")
		is_paused = true
	else:
		$PauseAnimation.play_backwards("pause_in")
		await $PauseAnimation.animation_finished
		
		#count time down
		var seconds = 3
		while seconds > 0:
			pause_label.text = "Continue in...\n" + str(seconds)
			await get_tree().create_timer(1.0).timeout
			seconds -= 1
		
		is_paused = false
		pause_screen.hide()
		get_tree().paused = false

func play_subtle_flow(sprite):
	var tween = create_tween().set_loops() # infinite loop
	# --- Rotation sway (left ↔ right) ---
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "rotation_degrees", 3, randf_range(1.5,2.0))
	tween.tween_property(sprite, "rotation_degrees", -3, randf_range(1.5,2.0))

func play_tween(tween_obj):
	var sprite = tween_obj
	var tween = create_tween().set_loops(1) # 0 = no auto loop
	# Squash down quickly
	tween.tween_property(
		sprite, "scale", Vector2(1.3, 0.7), 0.08
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Stretch up past normal
	tween.tween_property(
		sprite, "scale", Vector2(0.8, 1.4), 0.12
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Overshoot slightly
	tween.tween_property(
		sprite, "scale", Vector2(1.05, 0.95), 0.1
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Return to perfect normal
	tween.tween_property(
		sprite, "scale", Vector2.ONE, 0.15
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

#signals
func _on_pause_btn_pressed() -> void:
	
	
	game_pause()

func _on_btn_continue_pressed() -> void:
	AudioManager.play_sfx("SFX_Microgame-uiConfirm")
	
	restart_button.disabled = true
	quit_button.disabled = true
	game_pause()

func _on_btn_restart_pressed() -> void:
	AudioManager.play_sfx("SFX_Microgame-uiConfirm")
	
	continue_button.disabled = true
	quit_button.disabled = true
	
	is_paused = false
	get_tree().paused = false
	pause_label.text = "Restarting..."
	await get_tree().create_timer(1).timeout
	pause_screen.hide()

func _on_btn_quit_pressed() -> void:
	AudioManager.play_sfx("SFX_Microgame-uiConfirm")
	
	continue_button.disabled = true
	restart_button.disabled = true
	
	is_paused = false
	get_tree().paused = false
	pause_label.text = "Quiting..."
	await get_tree().create_timer(1).timeout
	pause_screen.hide()
