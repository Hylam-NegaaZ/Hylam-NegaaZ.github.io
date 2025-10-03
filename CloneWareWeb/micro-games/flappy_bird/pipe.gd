extends Area2D

signal hit
signal scored

func _ready() -> void:
	#drop shadow
	var shadow = $Lower.duplicate()
	shadow.modulate = Color(0, 0, 0, 0.5)
	shadow.position += Vector2(-5, 5)
	shadow.z_index = -1
	add_child(shadow)

func _on_body_entered(body):
	hit.emit()

func _on_score_area_body_entered(body):
	scored.emit()
