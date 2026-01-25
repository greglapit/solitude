extends Weapon

func assign_prop() -> void:
	rank = 2
	file_name = "2_base_weapon"
	display_name = "SI 02: DAGGERS"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Daggers"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/2/2_base_weapon.png")
	player_idle_anim = "2_base_idle"
	player_attack_anim = "2_base_attack"
	player_defend_anim = "2_base_defend"

func resolve_combat(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	combat_data = super(_player, _mini_card, _hp, _attacks, _enemy_array)
	if _enemy_array[0].rank == rank:
		critting = true
	return combat_data

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if critting:
		animation_player.play("double_slash")
	else:
		animation_player.play("slash")
