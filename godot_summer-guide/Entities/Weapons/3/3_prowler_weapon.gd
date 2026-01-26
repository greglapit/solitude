extends Weapon


func assign_prop() -> void:
	rank = 3
	file_name = "3_prowler_weapon"
	display_name = "Prowler"
	second_name = "Low Rank Hunter"
	description = "-Passive: Attacks before quicker ranks\n-Can't generate crit"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/3/3_prowler_weapon.png")
	player_idle_anim = "3_prowler_idle"
	player_attack_anim = "3_prowler_attack"
	player_defend_anim = "3_prowler_defend"
	has_special = false

	
func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("stab")
