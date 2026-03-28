extends Node2DScene

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func initialize() -> void:
	await get_tree().create_timer(2.0).timeout
	animation_player.play("hide")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"hide":
			change_scn.emit("res://Scenes/EnteringBattle/entering_battle.tscn", false, false)
