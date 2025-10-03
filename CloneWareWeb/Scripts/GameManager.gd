extends Node

var lives : int = 3
var microgames := [
	"res://micro-games/pong/Scenes/Pong_main.tscn",
	"res://micro-games/flappy_bird/main.tscn",
	"res://micro-games/find_the_differences/Scenes/ftd_main.tscn",
	"res://micro-games/match_three_tiles/mtt_main.tscn"
]
var last_game_index := 0
var stage_completed : int = 0
var stage_needed : int
var score : int = 0


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func gameStart() -> void:
	lives = 3
	stage_completed = 0

func loadMicrogame(mode_index):
	match mode_index:
		0:
		#region 10 Random Games Mode
			stage_needed = 10
			var random_index = randi_range(0, microgames.size() - 1)
			# loop to prevent reapeating game
			while last_game_index == random_index:
				random_index = randi_range(0, microgames.size() - 1)
			last_game_index = random_index
			
			var scene_path = microgames[random_index]
			return load(scene_path).instantiate()
		#endregion
		1:
		#region Endless Random Games Mode
			stage_needed = 999999999999999999
			var random_index = randi_range(0, microgames.size() - 1)
			# loop to prevent reapeating game
			while last_game_index == random_index:
				random_index = randi_range(0, microgames.size() - 1)
			last_game_index = random_index
			
			var scene_path = microgames[random_index]
			return load(scene_path).instantiate()
		#region end
		2:
		#region One Game Mode
			return load(microgames[1]).instantiate()
		#endregion
		_:
			AudioManager.play_sfx("SFX_Main-uiFobid")
			print("Error! No Mode Selected!")

func calc_score() -> int:
	if lives > 0:
		return stage_completed * lives + 1000
	else: return stage_completed * 1 + 1000

func lose_life():
	lives -= 1
