extends Weapon

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

func assign_prop() -> void:
	rank = 7
	file_name = "7_vamp_weapon"
	display_name = "Vamp"
	second_name = "FILLER FILLER FILLER"
	description = "-Special: Lifesteal\n-Cost: 3\n-Attack and heal for damage dealt"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "7_vamp_idle"
	player_attack_anim = "7_vamp_attack"
	player_defend_anim = "7_vamp_defend"
	player_special_anim = "7_vamp_special"
	has_special = true
	special_cost = 3

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if !using_special:
		animation_player.play("wide_slash")
	else:
		if enemies[0]:
			weapon_effects2.global_position = enemies[0].global_position
			weapon_effects2.z_index = enemies[0].z_index + 5
			animation_player2.play("shockwave")
	
func _on_player_special_impact() -> void:
	if !active:
		return
	var enemy_damage_taken : int = enemies[0].damage(rank)
	var heal : int = min(rank, enemy_damage_taken)
	combat_data["hp_delta"] = heal
	hp_update.emit(combat_data["hp_delta"])
