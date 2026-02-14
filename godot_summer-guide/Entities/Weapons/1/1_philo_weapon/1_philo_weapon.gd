extends Weapon

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_philo_weapon"
	display_name = "Philo"
	second_name = "Filler filler filler"
	description = "-Special: Heal 5\n-Cost: 1"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "1_philo_idle"
	player_attack_anim = "1_philo_attack"
	player_defend_anim = "1_philo_defend"
	player_special_anim = "1_philo_special"
	has_special = true
	special_cost = 1

func special_attack() -> Dictionary:
	using_special = true
	player.play(player_special_anim)
	return combat_data
	
func _on_player_special_impact() -> void:
	if !active:
		return
	combat_data["hp_delta"] = 5
	hp_update.emit(combat_data["hp_delta"])
	mini_equipped.used = true
	mini_equipped.play("used")
	mini_equipped.damage(combat_data["durability_delta"])
	weapon_used.emit(self)
	using_special = false

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
