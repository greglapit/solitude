extends Weapon

var swipe_dmg : int = 1
var final_swipe_dmg : int = 5

func equip() -> void:
	super()
	description = "-Special: Ravage\n-Cost: %d\n-Go on rampage, 4 striking enemies for %d and ending with %d" % [special_cost, swipe_dmg, final_swipe_dmg]


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
