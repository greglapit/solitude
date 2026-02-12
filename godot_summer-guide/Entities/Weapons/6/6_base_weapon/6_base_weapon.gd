extends Weapon

func assign_prop() -> void:
	rank = 6
	file_name = "6_base_weapon"
	display_name = "SI CHAIN"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Chain"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "6_base_idle"
	player_attack_anim = "6_base_attack"
	player_defend_anim = "6_base_defend"

func _on_player_weap_effect_start() -> void:
	animation_player.play("shockwave")
