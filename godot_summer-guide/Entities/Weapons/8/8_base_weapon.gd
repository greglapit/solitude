extends Weapon

func assign_prop() -> void:
	rank = 8
	file_name = "8_base_weapon"
	display_name = "SI 08: GIANT AXE"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Giant Axe \n-Special: FILLER"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/8/8_base_weapon.png")
	player_idle_anim = "8_base_idle"
	player_attack_anim = "8_base_attack"
	player_defend_anim = "8_base_defend"
