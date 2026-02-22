extends Weapon

var threshold : int = 4
var heal_amt : int = 3

func equip() -> void:
	description = "-Special: Consume\n-Cost: %d\n-Feed a weaker enemy to the gloves. Heal for %d" % [special_cost, heal_amt]

func has_valid_spec_target(_enemies : Array) -> bool:
	if _enemies[0] and _enemies[0].rank <= threshold:
		return true
	return false

func special_attack() -> Dictionary:
	update_node_refs()
	using_special = true
	player.play(player_special_anim)
	return combat_data

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("shockwave")

func _on_player_special_impact() -> void:
	if !active:
		return
	
	var target : Enemy = enemies[0]
	target.damage(min(target.rank, threshold))
	combat_data["hp_delta"] = heal_amt
	hp_update.emit(combat_data["hp_delta"])
