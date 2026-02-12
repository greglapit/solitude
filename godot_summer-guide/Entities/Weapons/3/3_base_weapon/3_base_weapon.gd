extends Weapon

func assign_prop() -> void:
	rank = 3
	file_name = "3_base_weapon"
	display_name = "SI SPEAR"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Spear"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "3_base_idle"
	player_attack_anim = "3_base_attack"
	player_defend_anim = "3_base_defend"

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("stab")
