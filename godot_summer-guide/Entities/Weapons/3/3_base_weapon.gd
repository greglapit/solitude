extends Weapon

func assign_prop() -> void:
	rank = 3
	file_name = "3_base_weapon"
	display_name = "SI 03: TRIDENT"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Trident \n-Special: Whirlpool"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/3/3_base_weapon.png")
	player_idle_anim = "3_base_idle"
	player_attack_anim = "3_base_attack"
	player_defend_anim = "3_base_defend"
