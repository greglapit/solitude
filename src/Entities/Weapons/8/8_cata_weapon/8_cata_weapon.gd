extends Weapon

@onready var damage : int = weap_data.int1
@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer


func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if !using_special:
		animation_player.play("shockwave")

func _on_player_special_impact() -> void:
	if !active:
		return
		
	weapon_effects2.global_position = player.global_position
	weapon_effects2.z_index = player.z_index - 1
	animation_player2.play("shockwave")
	for enemy : Enemy in enemies:
		enemy.damage(damage)
		
	pause.emit(self)
	await player.anim_finished
	player.play("base_dazed")
	player.dazed = true
	
	while enemies.is_empty():
		update_node_refs()
		await get_tree().process_frame
	
	var target : Enemy = enemies[0]
	await target.animation_player.animation_finished	# Wait for spawn
	await get_tree().create_timer(.5).timeout
	enemy_attack()
	
func _on_enemy_attack_impact(_enemy : Enemy) -> void:
	super(_enemy)
	player.dazed = false
	await player.anim_finished
	resume.emit(self)
