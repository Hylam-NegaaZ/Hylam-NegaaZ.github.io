extends Control

@onready var intro_screen := $IntroScreen
@onready var title_screen := $TitleScreen
@onready var gamemode_screen := $GamemodesScreen
@onready var transition_screen := $TransitionPanel
@onready var pause_screen := $PauseScreen

@onready var game_loader := $GameLoadScreen
@onready var main_animation_player := $Animation
@onready var transition_label_main := $TransitionPanel/TransitionLabel/MainLabel
@onready var transition_label_sub := $TransitionPanel/TransitionLabel/SubLabel

var tips = [
	"Wash your hand before playing this game",
	"Wash your eyes before playing find the differences",
	"The more game you pass, the harder the game is!"
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music("Main-titleScreen")
	#hide others
	intro_screen.show()
	pause_screen.show()
	title_screen.hide()
	gamemode_screen.hide()
	transition_screen.hide()
	$IntroScreen/IntroAnimation.play("intro")
	
	pause_screen.play_subtle_flow($TitleScreen/Title)
	#load first mode on lauch
	mode_desc_load(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("Full_Screen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

#region Modes Navigation & Descriptions loading
var modes_data := [
	{
		"mode_id": 0,
		"mode_name":"Classic Mode",
		"mode_description":"Enjoy the basic of CloneWare! Survive 10 levels: it’s beginner’s yoga for your thumbs.",
		"mode_thumbnail": "res://Assets/Gamemode_Classic-Thumbnail.png"
	},
	{
		"mode_id": 1,
		"mode_name":"Endless Mode",
		"mode_description":"Sometimes, 10 levels just aren’t enough punishment.",
		"mode_thumbnail": "res://Assets/Gamemode_Endless-Thumbnail.png"
	},
	{
		"mode_id": -1,
		"mode_name":"Locked",
		"mode_description":"The more you play, the more modes you get.",
		"mode_thumbnail": "res://Assets/Gamemode_Locked-Thumbnail.png"
	}
]
@onready var mode_thumbnail := $GamemodesScreen/ModeThumbnail
@onready var mode_title := $GamemodesScreen/ModeThumbnail/ModeTitle
@onready var mode_description := $GamemodesScreen/ModeThumbnail/DecsBox/ModeDesc
var chosen_mode : int = modes_data[0].mode_id
var mode_last_index := 0;

func mode_desc_load(mode_index) -> void:
	chosen_mode = modes_data[mode_index].mode_id
	mode_title.text = modes_data[mode_index].mode_name
	mode_description.text = modes_data[mode_index].mode_description
	mode_thumbnail.texture = load(modes_data[mode_index].mode_thumbnail)

#signals
func _on_mode_right_btn_pressed() -> void:
	AudioManager.play_sfx("SFX_Main-uiConfirm")
	
	var btn := $GamemodesScreen/ModeThumbnail/ModeRightBtn
	play_tween(btn.get_child(0))
	mode_last_index += 1
	if mode_last_index > len(modes_data)-1:
		mode_last_index = 0
		mode_desc_load(mode_last_index)
	else:
		mode_desc_load(mode_last_index)

func _on_mode_left_btn_pressed() -> void:
	AudioManager.play_sfx("SFX_Main-uiConfirm")
	
	var btn := $GamemodesScreen/ModeThumbnail/ModeLeftBtn
	play_tween(btn.get_child(0))
	mode_last_index -= 1
	if mode_last_index < 0:
		mode_last_index = len(modes_data)-1
		mode_desc_load(mode_last_index)
	else:
		mode_desc_load(mode_last_index)
#endregion


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
func _on_start_btn_pressed() -> void:
	AudioManager.play_sfx("SFX_Main-uiConfirm")
	AudioManager.play_sfx("SFX_Main-transition")
	play_tween($TitleScreen/StartBtn)
	transition_screen.show()
	main_animation_player.play("transition_in")
	await get_tree().create_timer(5).timeout
	AudioManager.play_music("Main-gameModes")
	title_screen.hide()
	gamemode_screen.show()
	main_animation_player.play("transition_out")
	await main_animation_player.animation_finished
	transition_screen.hide()
	
	main_animation_player.play("gamemode_startgame_label_idle")
	

func _on_setting_btn_pressed() -> void:
	AudioManager.play_sfx("SFX_Main-uiConfirm")
	
	play_tween($TitleScreen/SettingBtn)
	$Setting.show()
	main_animation_player.play("setting_in")
	await main_animation_player.animation_finished

func _on_close_btn_pressed() -> void:
	AudioManager.play_sfx("SFX_Main-uiConfirm")
	
	play_tween($Setting/SettingBackground/CloseBtn)
	main_animation_player.play("setting_out")
	await main_animation_player.animation_finished

func _on_play_btn_pressed() -> void:
	var game_stage = load("res://Scenes/GameStage.tscn").instantiate()
	game_stage.mode_index = chosen_mode
	
	if (game_stage.mode_index != -1):
		AudioManager.stop_music()
		AudioManager.play_sfx("SFX_Microgame-uiConfirm")
	
		if game_loader.get_children():
			game_loader.get_child(0).queue_free()
		transition_screen.show()
		main_animation_player.play("gamemode_startgame_label_begin")
		$GamemodesScreen/PlayBtn.disabled = true
		await main_animation_player.animation_finished
	
		game_loader.add_child(game_stage)
		# Listen for result signal from microgame
		game_stage.connect("gamestage_finished", Callable(self, "_on_gamestage_finished"))
		
		await get_tree().create_timer(1).timeout
		gamemode_screen.hide()
		$GamemodesScreen/PlayBtn.disabled = false
	else:
		AudioManager.play_sfx("SFX_Main-uiFobid")

##pause menu buttons
func _on_btn_restart_pressed() -> void:
	_on_play_btn_pressed()

func _on_btn_quit_pressed() -> void:
	_on_gamestage_finished()
##

func _on_tip_change_timeout() -> void:
	transition_label_sub.text = "Tips: " + tips.pick_random()

func _on_gamestage_finished():
	transition_screen.show()
	main_animation_player.play("transition_in")
	await get_tree().create_timer(5).timeout
		#queue_free GameStage
			
	if game_loader.get_children():
		game_loader.get_child(0).queue_free()
	title_screen.hide()
	gamemode_screen.show()
	main_animation_player.play("transition_out")
	await main_animation_player.animation_finished
	transition_screen.hide()
	
	main_animation_player.play("gamemode_startgame_label_idle")
