extends Weapon

@onready var heal_amt : int = weap_data.int1

# === Custom Methods ===========================================================
func special_attack() -> Dictionary:
	using_special = true
	player.play(player_special_anim)
	return combat_data
	
func _on_player_special_impact() -> void:
	if !active:
		return
	combat_data["hp_delta"] = heal_amt
	hp_update.emit(combat_data["hp_delta"])
	weapon_used.emit(self)
	using_special = false

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
