extends Weapon

# === Custom Methods ===========================================================	
func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
