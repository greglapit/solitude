extends Weapon


func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if !using_special:
		animation_player.play("shockwave")
	else:
		pause.emit(self)
		camera.play("pirate_weapon")


var impacts : int = 0
func _on_player_special_impact() -> void:
	if !active:
		return
	update_node_refs()
	if impacts < 2:
		for enemy : Enemy in enemies:
			enemy.damage(2)
		impacts += 1
	else:
		var remaining_dmg : int = max(weap_data.int1 - 4, 0)
		for enemy : Enemy in enemies:
			enemy.damage(remaining_dmg)
		impacts = 0
		resume.emit(self)
