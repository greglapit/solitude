extends Weapon

func assign_prop() -> void:
	rank = 10
	file_name = "10_pirate_weapon"
	display_name = "Pirate Wheel"
	second_name = "Filler Filler Filler"
	description = "-Special: Seaquake\n-Cost: 2\n-Slam enemies side to side, dealing 8 total damage."
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "10_pirate_idle"
	player_attack_anim = "10_pirate_attack"
	player_defend_anim = "10_pirate_defend"
	player_special_anim = "10_pirate_special"
	has_special = true
	special_cost = 2

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
		for enemy : Enemy in enemies:
			enemy.damage(4)
		impacts = 0
		resume.emit(self)
