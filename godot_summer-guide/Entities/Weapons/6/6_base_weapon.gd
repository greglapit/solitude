extends Weapon

func assign_prop() -> void:
	rank = 6
	file_name = "6_base_weapon"
	display_name = "SI 06: CHAIN"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Chain \n-Special: FILLER"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/6/6_base_weapon.png")
	player_idle_anim = "6_base_idle"
	player_attack_anim = "6_base_attack"
	player_defend_anim = "6_base_defend"
