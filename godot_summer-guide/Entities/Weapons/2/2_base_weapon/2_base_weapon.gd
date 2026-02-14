extends Weapon

func assign_prop() -> void:
	rank = 2
	file_name = "2_base_weapon"
	display_name = "SI DAGGERS"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Daggers"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "2_base_idle"
	player_attack_anim = "2_base_attack"
	player_defend_anim = "2_base_defend"

func resolve_combat() -> Dictionary:
	combat_data = super()
	if enemies[0].rank == rank:
		critting = true
	return combat_data

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")
