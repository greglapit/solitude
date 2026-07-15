extends Weapon
	
func special_attack() -> Dictionary:
	update_node_refs()
	if !has_special:
		push_error("No special to be called")
		return {}
	var dict : Dictionary = resolve_combat()
	using_special = true
	return dict

func has_valid_spec_target(_enemies : Array) -> bool:
	if _enemies[0].rank > rank:
		return true
	return false

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if !using_special:
		animation_player.play("shockwave")
	
func _on_player_attack_impact() -> void:
	if !active:
		return
	super()
	if using_special:
		await get_tree().create_timer(0.9).timeout	# play animation right before enemy attacks. Set float to .1 before anim finishes
		player.play(player_special_anim)

func _on_player_special_impact() -> void:
	if !active:
		return
	var target : Enemy = enemies[0]
	player.animation_player.pause()
	resolve_combat()
	await target.animation_player.animation_finished
	animation_player.play("shockwave")
	target.damage(min(target.rank, rank))
	await target.animation_player.animation_finished
	player.animation_player.play()
	
func _on_enemy_attack_impact(_enemy : Enemy) -> void:
	if !active:
		return
	if !using_special:
		super(_enemy)
	else:
		hp_update.emit(combat_data["hp_delta"])
	
