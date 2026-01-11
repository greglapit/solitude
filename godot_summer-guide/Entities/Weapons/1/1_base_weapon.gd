extends Weapon

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_base_weapon"
	display_name = "SI 01: FACET"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Gem \n-Special: Heal"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/1/1_base_weapon.png")
	player_idle_anim = "1_base_idle"
	player_attack_anim = "1_base_attack"
	player_defend_anim = "1_base_defend"
	
