extends Weapon

@onready var shockwave_effect : Sprite2D = $ShockwaveEffect
@onready var warp_effect : Sprite2D = $WarpEffect
@onready var animation_player2 : AnimationPlayer = $WarpEffect/AnimationPlayer

@onready var damage : int = weap_data.int1

func special_attack() -> Dictionary:
	update_node_refs()
	using_special = true
	player.play(player_special_anim)
	return combat_data

func _on_player_attack_impact() -> void:
	super()
	var target : Enemy = enemies[0]
	shockwave_effect.global_position = target.global_position
	shockwave_effect.z_index = target.z_index + 1
	weapon_effects.z_index = target.z_index - 1
	animation_player.play("ground_crack")
	pass
	
func _on_player_special_impact() -> void:
	if !active:
		return
	update_node_refs()
	warp_effect.global_position = player.global_position
	animation_player2.play("shockwave")
	for enemy : Enemy in enemies:
		enemy.play("shake")
		enemy.kneeling = true
		await get_tree().create_timer(.1).timeout
		
func _on_enemy_attack_prevented(enemy : Enemy) -> void:
	if enemy.kneeling:
		# ADD PLAYER ANIMATION PAUSE
		enemy.kneeling = false
		enemy.play("shake")
		await enemy.animation_player.animation_finished
		
	# Continues combat
	_on_player_anim_finished("defend")
