extends Control

var microgame_description := "Spot the \ndifferences!"
var description_font_size := 18

signal microgame_finished(win: bool)

var circles = load("res://micro-games/find_the_differences/Scenes/circle.tscn")
var diff_cicles := []

var win_messages = [
	"Sharp Eyes!",
	"Nice Spot!",
	"Found It!",
	"Good Eye!",
	"Well Spotted!",
	"You Saw It!",
	"Spot On!",
	"Eagle Eye!",
	"Gotcha!",
	"Difference Master!"
]
var lose_messages = [
	"Close Call!",
	"Almost There!",
	"Good Try!",
	"Nice Effort!",
	"So Close!",
	"Keep Going!",
	"Try Again!",
	"Not Bad!",
	"You Got This!",
	"Almost Spotted!",
]

@onready var original_image := $Origin
@onready var differences_image := $Differ
@onready var spot_timer := $SpotTimer
@onready var progress_bar := $ProgressBar

@onready var click_areas := $ClickAreas
@onready var label := $Label

var datas = {
	"type-1":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-1/original.jpg",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-1/diff-1.jpg"
		},
		"diff_spots":[
			Vector2(275,195),
			Vector2(275,555)
		],
		"spot_size": Vector2(50,50)
	},
	"type-2":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-1/original.jpg",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-1/diff-2.jpg"
		},
		"diff_spots":[
			Vector2(118,232),
			Vector2(118,593)
		],
		"spot_size": Vector2(50,50)
	},
	"type-3":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-2/original.jpg",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-2/diff-1.jpg"
		},
		"diff_spots":[
			Vector2(166,220),
			Vector2(166,575)
		],
		"spot_size": Vector2(50,50)
	},
	"type-4":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-2/original.jpg",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-2/diff-2.jpg"
		},
		"diff_spots":[
			Vector2(255,140),
			Vector2(255,505)
		],
		"spot_size": Vector2(50,50)
	},
	"type-5":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-3/original.png",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-3/diff-2.png"
		},
		"diff_spots":[
			Vector2(150,135),
			Vector2(150,495),
			Vector2(246,135),
			Vector2(246,495)
		],
		"spot_size": Vector2(50,50)
	},
	"type-6":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-3/original.png",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-3/diff-1.png"
		},
		"diff_spots":[
			Vector2(117,80),
			Vector2(117,440),
		],
		"spot_size": Vector2(50,50)
	},
	"type-7":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-4/original.jpg",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-4/diff-1.jpg"
		},
		"diff_spots":[
			Vector2(138,474),
			Vector2(138,110),
		],
		"spot_size": Vector2(50,50)
	},
	"type-8":{
		"images": {
			"og_img": "res://micro-games/find_the_differences/Assets/images/type-4/original.jpg",
			"diff_img": "res://micro-games/find_the_differences/Assets/images/type-4/diff-2.jpg"
		},
		"diff_spots":[
			Vector2(207,200),
			Vector2(207,560),
		],
		"spot_size": Vector2(50,50)
	}
}


func _ready() -> void:
	AudioManager.play_music("FindTheDifferences-background")
	
	original_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	differences_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	game_start()

func _process(delta: float) -> void:
	if (!spot_timer.is_stopped()):
		progress_bar.value = spot_timer.time_left

func game_start():
	spot_timer.start()
	var keys = datas.keys()
	var random_type = keys[randi() % keys.size()]
	load_round(datas[random_type])

func load_round(round_data):
	# Load images
	original_image.texture = load(round_data["images"]["og_img"])
	differences_image.texture = load(round_data["images"]["diff_img"])
	
	# Clear old click areas
	for c in click_areas.get_children():
		c.queue_free()
	
	# Create clickable spots
	for pos in round_data["diff_spots"]:
		#spawn different location a hidden cirlce
		
		var circle_obj = circles.instantiate()
		circle_obj.position = pos
		add_child(circle_obj)
		circle_obj.visible = false
		diff_cicles.append(circle_obj)
		
		var spot = ColorRect.new()
		spot.color = Color(0,0,0,0) # semi-transparent for debugging
		spot.size = round_data["spot_size"] # clickable area size
		spot.position = pos - spot.size/2
		spot.mouse_filter = Control.MOUSE_FILTER_STOP
		spot.connect("gui_input", Callable(self, "_on_spot_clicked").bind(spot))
		click_areas.add_child(spot)

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

func _on_spot_clicked(event: InputEvent, spot: Control):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		AudioManager.play_sfx("SFX_Main-gameStart")
		show_answer()
		spot_timer.stop()
		finish_game(true)

func finish_game(win: bool):
	AudioManager.stop_music()
	
	click_areas.queue_free()
	progress_bar.visible = false
	label.visible = true
	if win:
		label.text = win_messages.pick_random()
		play_tween(label)
		await get_tree().create_timer(2).timeout
	else:
		label.text = lose_messages.pick_random()
		play_tween(label)
		await get_tree().create_timer(2).timeout
	emit_signal("microgame_finished", win)

func show_answer():
	for c in diff_cicles:
		c.visible = true
		c.get_node("AnimatedSprite2D").play()
		play_tween(c)

func _on_spot_timer_timeout() -> void:
	show_answer()
	finish_game(false)
