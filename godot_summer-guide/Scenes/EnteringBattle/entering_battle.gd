extends Node2DScene

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func initialize() -> void:
	change_scn.emit("res://Scenes/Battle/battle.tscn", false, true)
	animated_sprite.play("default")


func _on_animated_sprite_2d_animation_finished() -> void:
	scene_ready_for_swap.emit()
