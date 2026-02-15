extends Weapon

var player_damage : int = 4
var aoe_damage : int = 2

func assign_prop() -> void:
	rank = 8
	file_name = "8_splitter_weapon"
	display_name = "Skysplitter"
	second_name = "FILLER FILLER FILLER"
	description = "-Passive: Reckless Strikes\n-Attacks do %d aoe, but damage player %d in process. Cannot die from attacking." % [aoe_damage, player_damage]
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "8_splitter_idle"
	player_attack_anim = "8_splitter_attack"
	player_defend_anim = "8_splitter_defend"
	has_special = false
	special_cost = 0

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
		await get_tree().create_timer(.1).timeout
	combat_data["hp_delta"] = -min(player_damage, abs(hp - 1))
	hp_update.emit(combat_data["hp_delta"])
