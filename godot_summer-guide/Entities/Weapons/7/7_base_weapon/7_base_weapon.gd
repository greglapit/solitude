extends Weapon

func _on_player_weap_effect_start() -> void:
	animation_player.play("wide_slash")
