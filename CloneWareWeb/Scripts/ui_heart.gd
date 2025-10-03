extends Control
@onready var sprite := $AnimatedSprite2D
@onready var particles := $CPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func heart_break():
	sprite.play("break")
	await get_tree().create_timer(1).timeout
	sprite.visible = false
	particles.emitting = true
	await get_tree().create_timer(3).timeout
	queue_free()
