extends Weapon

var player_damage : int = 4
var aoe_damage : int = 2

func equip() -> void:
	super()
	description = "-Passive: Reckless Strikes\n-Cost: %d\n-Attacks do %d aoe, \
					but damage player %d in process. Cannot die from attacking." \
					% [special_cost, aoe_damage, player_damage]

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("upward_slash")

func _on_player_attack_impact() -> void:
	super()
	for enemy : Enemy in enemies:
		if enemy == enemies[0]:
			continue
		enemy.damage(aoe_damage)
	combat_data["hp_delta"] = -min(player_damage, abs(hp - 1))
	hp_update.emit(combat_data["hp_delta"])
