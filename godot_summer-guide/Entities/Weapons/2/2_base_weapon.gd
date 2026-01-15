extends Weapon

func assign_prop() -> void:
	rank = 2
	file_name = "2_base_weapon"
	display_name = "SI 02: DAGGERS"
	second_name = "Diamond Court Standard Issue"
	description = "-Standard Issue Daggers \n-Special: Marks"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/2/2_base_weapon.png")
	player_idle_anim = "2_base_idle"
	player_attack_anim = "2_base_attack"
	player_defend_anim = "2_base_defend"
