extends Weapon

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer


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
