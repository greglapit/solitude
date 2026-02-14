extends Weapon

func assign_prop() -> void:
	rank = 4
	file_name = "4_mirra_weapon"
	display_name = "Mirra"
	second_name = "Filler Filler Filler"
	description = "-Special: Reflect\n-Cost: 1\n-Attack. Then defend and mirror enemy damage, up to 4."
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "4_mirra_idle"
	player_attack_anim = "4_mirra_attack"
	player_defend_anim = "4_mirra_defend"
	player_special_anim = "4_mirra_special"
	has_special = true
	special_cost = 1
	
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
	
