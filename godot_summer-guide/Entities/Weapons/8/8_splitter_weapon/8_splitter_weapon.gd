extends Weapon

@onready var aoe_damage : int = 2
@onready var player_damage : int = 4


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
