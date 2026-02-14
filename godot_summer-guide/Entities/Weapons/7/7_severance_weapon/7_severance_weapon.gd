extends Weapon

var threshold : int = 7
var exe_enemies : Array
var death_mark_scn : PackedScene
var enemy_mark_dict : Dictionary

func assign_prop() -> void:
	rank = 7
	file_name = "7_severance_weapon"
	display_name = "Severance"
	second_name = "FILLER FILLER FILLER"
	description = "-Special: Execute\n-Cost: %d\n-Execute all enemies below %d" % [special_cost, threshold]
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "7_severance_idle"
	player_attack_anim = "7_severance_attack"
	player_defend_anim = "7_severance_defend"
	player_special_anim = "7_severance_special"
	has_special = true
	special_cost = 2

func equip() -> void:
	super()
	for enemy : Enemy in enemies:
		_on_enemy_rank_update(enemy.rank, enemy)

func unequip() -> void:
	super()
	for enemy : Enemy in exe_enemies.duplicate():
		var death_mark : AnimatedSprite2D = enemy_mark_dict[enemy]
		death_mark.queue_free()
		enemy_mark_dict.erase(enemy)
		exe_enemies.erase(enemy)

func has_valid_spec_target(_enemies : Array) -> bool:
	for enemy : Enemy in _enemies:
		if enemy.rank < threshold:
			return true
	return false

func _ready() -> void:
	super()
	death_mark_scn = load("res://Entities/Weapons/ArtWeaponEffects/death_mark.tscn")

func _on_player_weap_effect_start() -> void:
	if !using_special:
		animation_player.play("wide_slash")
	
func _on_player_special_impact() -> void:
	if !active:
		return
	
	player.animation_player.pause()
	pause.emit(self)
	for enemy : Enemy in exe_enemies.duplicate():
		weapon_effects.global_position = enemy.global_position
		weapon_effects.z_index = enemy.z_index + 1
		animation_player.play("double_slash")
		var death_mark : AnimatedSprite2D = enemy_mark_dict[enemy]
		death_mark.queue_free()
		exe_enemies.erase(enemy)
		enemy.play("death")
		await get_tree().create_timer(.5).timeout
	
	player.animation_player.play()
	await player.anim_finished
	resume.emit(self)
	
func _on_enemy_spawned(enemy : Enemy) -> void:
	if !active:
		return
	_on_enemy_rank_update(enemy.rank,enemy)
	
func _on_enemy_rank_update(_new_rank : int, enemy : Enemy) -> void:
	if crit_stored < special_cost:
		return
	if enemy not in exe_enemies:
		if enemy.rank < threshold:
			var death_mark : AnimatedSprite2D = death_mark_scn.instantiate()
			enemy.add_child(death_mark)
			enemy_mark_dict[enemy] = death_mark
			exe_enemies.append(enemy)
	else:
		if enemy.rank >= threshold:
			var death_mark : AnimatedSprite2D = enemy_mark_dict[enemy]
			death_mark.queue_free()
			enemy_mark_dict.erase(enemy)
			exe_enemies.erase(enemy)
