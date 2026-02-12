extends Weapon

var barrier : bool = false

func assign_prop() -> void:
	rank = 4
	file_name = "4_bastion_weapon"
	display_name = "04: Bastion"
	second_name = "Filler Filler Filler"
	description = "-Special: Barrier.\n-Cost=1\nReduce next enemy attack to 1."
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "4_bastion_idle"
	player_attack_anim = "4_bastion_attack"
	player_defend_anim = "4_bastion_defend"
	player_special_anim = "4_bastion_special"
	has_special = true
	special_cost = 1
	
func special_attack(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
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
	
func _on_enemy_attack_impact() -> void:
	if !active and !barrier:
		return
		
	if barrier:
		barrier = false
		player.effect("RESET")
		combat_data["hp_delta"] = max(combat_data["hp_delta"], -1)
	super()
		
	
