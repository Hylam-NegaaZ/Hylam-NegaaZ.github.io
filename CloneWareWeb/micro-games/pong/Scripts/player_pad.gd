extends CharacterBody2D

@onready var match_controller : PongMatchController = get_parent()

var speed : float = 600.0
var p_height : int

func _ready() -> void:
	p_height = $CollisionBox.shape.get_size().y
	
	#drop shadow
	var shadow = $DrawSprite.duplicate()
	shadow.modulate = Color(0, 0, 0, 0.2)
	shadow.position += Vector2(-5, 5)
	shadow.z_index = -1
	add_child(shadow)

func _physics_process(delta: float) -> void:
	#movement logic
	var direction := Input.get_axis("Move_Up","Move_Down")
	if direction:
		position.y += direction * speed * delta
	
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

#signals
