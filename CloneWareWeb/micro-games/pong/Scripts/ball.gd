extends CharacterBody2D
class_name Ball

@onready var match_controller : PongMatchController = get_parent()
@export var acceleration : int = 100

const INITIAL_SPEED : float = 200.0
const MAX_Y_VECTOR : float = 0.6

#var last_collider = null
var speed : int
var dir : Vector2

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	move_and_bounce(delta)

func new_ball():
	speed = INITIAL_SPEED
	dir = random_direction()

func move_and_bounce(delta: float):
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if (collider == match_controller.player_paddle) or (collider == match_controller.cpu_paddle) :
			speed = speed + acceleration
			dir = new_direction(collider)
			$SFX/pingSFX.play()
			#tween play when collide
			collider.play_tween()
		elif collider:
			dir = dir.bounce(collision.get_normal())

func random_direction():
	var new_dir := Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1,1)
	return new_dir.normalized()

func new_direction(collider):
	var ball_y = position.y
	var pad_y = collider.position.y
	var dist = ball_y - pad_y
	var new_dir := Vector2()
	
	#flip horizontal dir
	if dir.x > 0:
		new_dir.x = -1
	else:
		new_dir.x = 1
	new_dir.y = (dist / (collider.p_height / 2)) * MAX_Y_VECTOR
	return new_dir.normalized()
