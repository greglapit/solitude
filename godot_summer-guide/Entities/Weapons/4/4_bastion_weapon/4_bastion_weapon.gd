extends Weapon

var barrier : bool = false
	
func special_attack() -> Dictionary:
	update_node_refs()
	# Always put up barrier before attack
	using_special = true
	player.play(player_special_anim)
	await player.anim_finished
	
	return combat_data

func has_valid_spec_target(_enemies : Array) -> bool:
	if barrier:
		return false
	return true

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if !using_special:
		animation_player.play("shockwave")
	
func _on_player_special_impact() -> void:
	if !active:
		return
	player.effect("barrier")
	barrier = true
	
func _on_enemy_attack_impact(_enemy : Enemy) -> void:
	if !active and !barrier:
		return
	if barrier:
		barrier = false
		player.effect("RESET")
		combat_data["hp_delta"] = max(combat_data["hp_delta"], -1)
		
	super(_enemy)
	
