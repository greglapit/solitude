extends Weapon

var swipe_dmg : int = 1
var final_swipe_dmg : int = 5

func assign_prop() -> void:
	rank = 5
	file_name = "5_claw_weapon"
	display_name = "Fanghand"
	second_name = "Filler Filler Filler"
	description = "-Special: Ravage\n-Cost: 2\n-Go on rampage, 4 striking enemies for %d and ending with %d" % [swipe_dmg, final_swipe_dmg]
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "5_claw_idle"
	player_attack_anim = "5_claw_attack"
	player_defend_anim = "5_claw_defend"
	player_special_anim = "5_claw_special"
	has_special = true
	special_cost = 2


var slash_counter : int = 0
func _on_player_special_impact() -> void:
	if !active:
		return
	enemies = enemies.filter(func(e : Enemy) -> bool: return e != null and not e.is_dead)
	if enemies.size() == 0:
		equip()
		combat_fin.emit()
		reciprocal_attack = false
		critting = false
		enemy_died = false
		using_special = false
		slash_counter = 0
		return
		
	var target : Enemy = enemies[randi() % enemies.size()]
	weapon_effects.position = target.position
	weapon_effects.z_index = target.z_index + 1

	if slash_counter == 4:
		animation_player.play("both_slash")
		target.damage(final_swipe_dmg)
		slash_counter = 0
		return
	
	if slash_counter % 2 == 0:
		animation_player.play("left_slash")
	else:
		animation_player.play("right_slash")
	target.damage(swipe_dmg)
	slash_counter += 1
