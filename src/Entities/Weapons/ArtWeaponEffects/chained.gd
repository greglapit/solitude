extends AnimatedSprite2D

func _on_animation_finished() -> void:
	match animation:
		"spawn":
			play("constant")
		"break":
			queue_free()
		"activate":
			queue_free()
