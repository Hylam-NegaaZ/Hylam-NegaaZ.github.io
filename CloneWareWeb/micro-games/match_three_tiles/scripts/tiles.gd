extends Control

signal tile_pressed(tile)

var tile_text : String = "Test"
var tile_size : float = 200
@onready var touch_area = $TouchArea
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	self.custom_minimum_size = Vector2(tile_size,tile_size)*0.9
	touch_area.shape.size = Vector2(tile_size,tile_size)*0.9
	touch_area.position = self.custom_minimum_size / 2
	$AnimatedSprite2D.position = self.custom_minimum_size / 2

	set_image()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_image():
	var data = [
		"res://micro-games/match_three_tiles/assets/mtt-icon_strawberry.png",
		"res://micro-games/match_three_tiles/assets/mtt-icon_peach.png",
		"res://micro-games/match_three_tiles/assets/mtt-icon_orange.png",
		"res://micro-games/match_three_tiles/assets/mtt-icon_grape.png",
		"res://micro-games/match_three_tiles/assets/mtt-icon_cherry.png",
		"res://micro-games/match_three_tiles/assets/mtt-icon_apple.png"
	]
	var image
	match tile_text:
		"Test": image = data[0]
		"1": image = data[1]
		"2": image = data[2]
		"3": image = data[3]
		"4": image = data[4]
		"5": image = data[5]
	self.texture = load(image)

func _on_touch_area_pressed() -> void:
	emit_signal("tile_pressed", self)
