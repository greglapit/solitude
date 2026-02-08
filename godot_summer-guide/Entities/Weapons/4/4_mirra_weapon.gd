extends Weapon

func assign_prop() -> void:
	rank = 4
	file_name = "4_mirra_weapon"
	display_name = "04: Mirra"
	second_name = "Filler Filler Filler"
	description = "-Special: Attack. Then defend and mirror enemy damage, up to 4."
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/4/4_mirra_weapon.png")
	player_idle_anim = "4_mirra_idle"
	player_attack_anim = "4_mirra_attack"
	player_defend_anim = "4_mirra_defend"
	player_special_anim = "4_mirra_special"
	has_special = true
	special_cost = 1
	
func special_attack(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	if !has_special:
		push_error("No special to be called")
		return {}
	var dict : Dictionary = resolve_combat(_player, _mini_card, _hp, _attacks, _enemy_array)
	using_special = true
	return dict

func has_valid_spec_target(_enemies : Array) -> bool:
	if _enemies[0].rank > rank:
		return true
	return false

func _on_player_weap_effect_start() -> void:
	if !using_special:
		animation_player.play("shockwave")
	
func _on_player_attack_impact() -> void:
	super()
	if using_special:
		player.play(player_special_anim)

func _on_player_special_impact() -> void:
	if !active:
		return
	var target : Enemy = enemies[0]
	player.animation_player.pause()
	resolve_combat(player,mini_equipped,hp,0,enemies)
	await target.animation_player.animation_finished
	animation_player.play("shockwave")
	target.damage(min(target.rank, rank))
	await target.animation_player.animation_finished
	player.animation_player.play()
	
func _on_enemy_attack_impact() -> void:
	if !active:
		return
	if !using_special:
		super()
	else:
		hp_update.emit(combat_data["hp_delta"])
	
