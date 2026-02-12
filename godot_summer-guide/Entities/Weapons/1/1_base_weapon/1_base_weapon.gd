extends Weapon

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_base_weapon"
	display_name = "SI FACET"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Gem"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "1_base_idle"
	player_attack_anim = "1_base_attack"
	player_defend_anim = "1_base_defend"
	
func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
