extends Weapon

@onready var threshold : int = weap_data.int1
var exe_enemies : Array
var death_mark_scn : PackedScene
var enemy_mark_dict : Dictionary

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
	equip()
	resume.emit(self)
	
func _on_enemy_spawned(enemy : Enemy) -> void:
	if !active:
		return
	_on_enemy_rank_update(enemy.rank,enemy)
	
func _on_enemy_rank_update(_new_rank : int, enemy : Enemy) -> void:
	if crits_stored < special_cost:
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

func _on_enemy_freed(_enemy : Enemy) -> void:
	exe_enemies.erase(_enemy)
