extends Weapon

func assign_prop() -> void:
	rank = 5
	file_name = "5_base_weapon"
	display_name = "SI GAUNTLETS"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Gauntlets"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "5_base_idle"
	player_attack_anim = "5_base_attack"
	player_defend_anim = "5_base_defend"

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("earth_crack")
	
func resolve_combat(_player : Node2D,_mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	combat_data = super(_player,_mini_card, _hp, _attacks, _enemy_array)
	weapon_effects.z_index = enemies[0].z_index - 1
	return combat_data
