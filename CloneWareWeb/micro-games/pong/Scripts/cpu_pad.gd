extends CharacterBody2D

@onready var match_controller : PongMatchController = get_parent()

var ball_pos : Vector2
var dist : int
var move_by : int
var speed : float = 150.0

var is_powered_up : bool = false
var p_height : int

func _ready() -> void:
	speed = clamp(1.0 + float(GameManager.stage_completed / 5), 150.0, 400.0)
	p_height = $CollisionBox.shape.get_size().y
	
	#drop shadow
	var shadow = $DrawSprite.duplicate()
	shadow.modulate = Color(0, 0, 0, 0.2)
	shadow.position += Vector2(-5, 5)
	shadow.z_index = -1
	add_child(shadow)



func _physics_process(delta: float) -> void:
	# Move paddle near ball
	if match_controller.ball_instance:
		ball_pos = match_controller.ball_instance.position
	dist = position.y - ball_pos.y
	
	if abs(dist) > speed * delta:
		move_by = speed * delta * (dist / abs(dist))
	else:
		move_by = dist
	
	position.y -= move_by
	
	# Clamp to camera-visible bounds
	var viewport_size = get_viewport_rect().size
	var half_height = p_height / 2
	position.y = clamp(position.y, half_height, viewport_size.y - half_height)

func play_tween():
	var sprite := $DrawSprite
	var tween = create_tween().set_loops(1) # 0 = no auto loop
	 # Squash down
	tween.tween_property(
		sprite, "scale", Vector2(1.2, 0.8), 0.15
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
		# Stretch up
	tween.tween_property(
		sprite, "scale", Vector2(0.9, 1.1), 0.15
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
		# Return to normal
	tween.tween_property(
		sprite, "scale", Vector2.ONE, 0.2
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
