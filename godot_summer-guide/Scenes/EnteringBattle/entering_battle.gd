extends Node2DScene

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func initialize() -> void:
	animated_sprite.play("default")


func _on_animated_sprite_2d_animation_finished() -> void:
	change_scn.emit("res://Scenes/Battle/battle.tscn", false, true)
