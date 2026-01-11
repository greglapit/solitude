extends Weapon

func assign_prop() -> void:
	rank = 9
	file_name = "9_base_weapon"
	display_name = "SI 09: STAFF"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Staff \n-Special: FILLER"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/9/9_base_weapon.png")
	player_idle_anim = "9_base_idle"
	player_attack_anim = "9_base_attack"
	player_defend_anim = "9_base_defend"
