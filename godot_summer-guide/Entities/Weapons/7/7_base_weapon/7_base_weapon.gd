extends Weapon

func assign_prop() -> void:
	rank = 7
	file_name = "7_base_weapon"
	display_name = "SI SCYTHE"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Scythe"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "7_base_idle"
	player_attack_anim = "7_base_attack"
	player_defend_anim = "7_base_defend"

func _on_player_weap_effect_start() -> void:
	animation_player.play("wide_slash")
