extends Weapon

func resolve_combat() -> Dictionary:
	combat_data = super()
	if enemies[0].rank == rank:
		critting = true
	return combat_data

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")
