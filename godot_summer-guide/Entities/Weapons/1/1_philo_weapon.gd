extends Weapon

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_philo_weapon"
	display_name = "Rose"
	second_name = "Filler filler filler"
	description = "-Special: Heal 5"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/1/1_philo_weapon.png")
	player_idle_anim = "1_philo_idle"
	player_attack_anim = "1_philo_attack"
	player_defend_anim = "1_philo_defend"
	player_special_anim = "1_philo_special"
	has_special = true

func special_attack(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	using_special = true
	player.play(player_special_anim)
	return {}
	
func _on_player_special_impact() -> void:
	if !active:
		return
	if using_special:
		combat_data["hp_delta"] = 5
		hp_update.emit(combat_data["hp_delta"])
		weapon_used.emit(self)
	using_special = false

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
