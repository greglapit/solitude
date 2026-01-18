extends Weapon

func assign_prop() -> void:
	rank = 10
	file_name = "10_base_weapon"
	display_name = "SI 10: CHARM"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Charm \n-Special: FILLER"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/10/10_base_weapon.png")
	player_idle_anim = "10_base_idle"
	player_attack_anim = "10_base_attack"
	player_defend_anim = "10_base_defend"

func _on_player_weap_effect_start() -> void:
	animation_player.play("shockwave")
