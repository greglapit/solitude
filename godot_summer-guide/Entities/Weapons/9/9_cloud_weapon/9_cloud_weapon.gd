extends Weapon

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2

func assign_prop() -> void:
	rank = 9
	file_name = "9_cloud_weapon"
	display_name = "Cloudreign"
	second_name = "FILLER FILLER FILLER"
	description = "-Special: Counter\n-Cost: 1\n-Dodge enemy attack, then strike back. (Enemy attacking restarts combat, giving you a free turn.)"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "9_cloud_idle"
	player_attack_anim = "9_cloud_attack"
	player_defend_anim = "9_cloud_defend"
	player_special_anim = "9_cloud_special"
	has_special = true
	special_cost = 1

func special_attack() -> Dictionary:
	update_node_refs()
	using_special = true
	player.play(player_special_anim)
	return combat_data

func _on_player_attack_impact() -> void:
	super()
	var target : Enemy = enemies[0]
	weapon_effects2.global_position = target.global_position
	weapon_effects2.z_index = target.z_index + 1
	weapon_effects.z_index = target.z_index - 1
	animation_player.play("ground_crack")
	pass
	
func _on_player_special_impact() -> void:
	if !active:
		return
		
	enemy_attack()
	
func _on_enemy_attack_impact(_enemy : Enemy) -> void:
	if !using_special:
		super(_enemy)
		return
	else:
		combat_data["durability_delta"] = 0
		pause.emit(self)
		# Wait for enemy to stop attacking
		while _enemy.animation_player.current_animation.contains("attack"):
			if player.animation_player.current_animation == "":
				player.play(player_special_anim)
			await get_tree().process_frame
		
		if player.animation_player.current_animation != "":
			await player.anim_finished
			
		combat_data["durability_delta"] = -1
		player.play(player_attack_anim)
		await player.anim_finished
		resume.emit(self)
		combat_fin.emit()
