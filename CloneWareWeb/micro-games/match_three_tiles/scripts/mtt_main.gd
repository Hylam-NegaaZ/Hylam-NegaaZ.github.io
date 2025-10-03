extends Microgame

@export var tile_base : PackedScene
@onready var container := $Board

func _ready() -> void:
	microgame_description = "Try Matching 3!"
	description_font_size = 20
	
	AudioManager.play_music("MatchThreeTiles-background")
	difficuty_set()
	$PlayTimer.start()
	$ProgressBar.max_value = $PlayTimer.wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!$PlayTimer.is_stopped()):
		$ProgressBar.value = $PlayTimer.time_left

func set_board(size_x, size_y, rows: int , columns: int):
	#clear children
	for c in container.get_children(): 
		c.queue_free()
	var board = get_node("Board")
	board.custom_minimum_size = Vector2(size_x, size_y)
	tiles_generated.clear()
	gen_tiles(rows,columns)
	for i in rows:
		var new_v_container = VBoxContainer.new()
		new_v_container.SIZE_EXPAND_FILL
		
		var new_h_container = HBoxContainer.new()
		new_h_container.alignment = BoxContainer.ALIGNMENT_CENTER
		new_h_container.SIZE_EXPAND_FILL
		
		new_v_container.add_child(new_h_container)
		board.add_child(new_v_container)
		spawn_tile(tiles_generated, new_h_container, columns, size_x/rows, true)

var tiles_generated = []
func gen_tiles(rows: int,columns: int):
	var amount : int = rows * columns
	amount -= amount % 3
	
	var random_tile = []
	var tile_id = [
		{"1": 0},
		{"2": 0},
		{"3": 0},
		{"4": 0},
		{"5": 0}
	]
	
	#generate an amounts of tiles
	for i in (amount / 3):
		var dict = tile_id.pick_random()      # Pick one dictionary
		var key = dict.keys()[0]              # Get the key (string)
		dict[key] = dict[key] + 3             # Update its value
	
	#create array of tile
	var total_available = 0
	for d in tile_id:
		total_available += d.values()[0]

	if amount > total_available:
		push_error("Not enough tiles to generate!")
		return
	var i = 0
	while i < amount:
		var dict = tile_id.pick_random()
		var key = dict.keys()[0]
		if dict[key] > 0:
			tiles_generated.append(key)
			dict[key] -= 1
			i += 1
		else:
			continue


func spawn_tile(tiles_array: Array, container: HBoxContainer, columns: int, size: float, pop: bool):
	if pop:
		for i in columns:
			if tiles_array.is_empty():
				push_warning("No more tiles to generate!")
				return
			var tile_pop = tile_base.instantiate()
			tile_pop.tile_text = tiles_array.pop_front()
			tile_pop.tile_size = size
			container.add_child(tile_pop)
			
			tile_pop.tile_pressed.connect(calc_tile)
	else:
		if tiles_array.is_empty():
			push_warning("No more tiles to generate!")
			return
		
		for t in tiles_array.size():
			var tile_unpop = tile_base.instantiate()
			tile_unpop.tile_text = tiles_array[t]
			tile_unpop.tile_size = size
			container.add_child(tile_unpop)
			tile_unpop.touch_area.queue_free()
			tile_unpop.sprite.apply_scale(Vector2(0.7,0.7))
			tile_unpop.tile_pressed.connect(calc_tile)

var pressed_tiles: Array = []
func calc_tile(tile):
	if pressed_tiles.size() < 4:
		AudioManager.play_sfx("SFX_Main-uiConfirm")
		tile.queue_free()
		pressed_tiles.append(tile.tile_text)
		
		if (pressed_tiles.size() >= 3):
			for i in range(pressed_tiles.size() - 2):
				if (pressed_tiles[i] == pressed_tiles[i + 1] 
				and pressed_tiles[i] == pressed_tiles[i + 2]):
					AudioManager.play_sfx("SFX_MatchThreeTiles-yay")
					$CPUParticles2D.emitting = false
					$CPUParticles2D.emitting = true
					for j in range(3):
						pressed_tiles.pop_back()
		for c in $Panel/HBoxContainer.get_children():
			c.queue_free()
		
		spawn_tile(pressed_tiles,$Panel/HBoxContainer,0,64,false)
	else:
		AudioManager.play_sfx("SFX_Main-uiFobid")

func is_winable() -> bool:
	for c in $Board.get_children():
		for d in c.get_children():
			if d.get_child_count() > 0:
				return false
	return true

func difficuty_set() -> void:
	var set = clamp(1 + int(GameManager.stage_completed / 5), 1, 3) 
	match set:
		1:
			set_board(350,350,3,3)
			$PlayTimer.wait_time = 9.0
		2:
			set_board(400,350,4,3)
			$PlayTimer.wait_time = 8.0
		3:
			set_board(500,590,5,3)
			$PlayTimer.wait_time = 7.5


func play_bounce(tween_obj):
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

#signals
func _on_spot_timer_timeout() -> void:
	container.hide()
	if is_winable():
		AudioManager.play_sfx("SFX_Main-gameStart")
		$CongratLabel.text = "Nice Work!"
		play_bounce($CongratLabel)
		await get_tree().create_timer(0.5).timeout
		finish_game(true)
	else:
		$CongratLabel.text = "You Can Do It!"
		play_bounce($CongratLabel)
		await get_tree().create_timer(0.5).timeout
		finish_game(false)
