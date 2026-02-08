extends Weapon

func assign_prop() -> void:
	rank = 4
	file_name = "4_base_weapon"
	display_name = "SI 04: SHIELD"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Shield"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/4/4_base_weapon.png")
	player_idle_anim = "4_base_idle"
	player_attack_anim = "4_base_attack"
	player_defend_anim = "4_base_defend"

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("shockwave")
