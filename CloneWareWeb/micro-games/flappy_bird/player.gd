extends CharacterBody2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600
const FLAP_SPEED : int = -500
const GLIDE_SPEED : int = 1
var flying : bool = false
var falling : bool = false
var is_gliding : bool = false
const START_POS = Vector2(100,400)

func _ready():
	reset();

func reset():
	is_gliding = false
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	
func _physics_process(delta):
	if flying or falling:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$AnimatedSprite2D.play()
		elif falling:
			set_rotation(PI/2)
			$AnimatedSprite2D.stop()
		move_and_collide(velocity * delta)
	else:
		$AnimatedSprite2D.stop()

func flap():
	play_tween(self)
	velocity.y = FLAP_SPEED

func glide():
	velocity.y = GLIDE_SPEED

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
