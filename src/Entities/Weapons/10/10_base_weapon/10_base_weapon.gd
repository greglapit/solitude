extends Weapon

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("shockwave")
