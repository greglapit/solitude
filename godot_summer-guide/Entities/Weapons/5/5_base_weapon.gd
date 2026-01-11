extends Weapon

func assign_prop() -> void:
	rank = 5
	file_name = "5_base_weapon"
	display_name = "SI 05: GAUNTLETS"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Gauntlets \n-Special: FILLER"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/5/5_base_weapon.png")
	player_idle_anim = "5_base_idle"
	player_attack_anim = "5_base_attack"
	player_defend_anim = "5_base_defend"
