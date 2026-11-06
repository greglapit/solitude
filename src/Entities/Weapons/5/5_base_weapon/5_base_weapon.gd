extends Weapon

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	weapon_effects.z_index = enemies[0].z_index - 1
	animation_player.play("earth_crack")
