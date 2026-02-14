extends Weapon


func assign_prop() -> void:
	rank = 3
	file_name = "3_trident_weapon"
	display_name = "Stormprong"
	second_name = "Filler Filler Filler"
	description = "-Special: Hurricane \n-Cost: 2 \n-Aoe 2 Damage"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "3_trident_idle"
	player_attack_anim = "3_trident_attack"
	player_defend_anim = "3_trident_defend"
	player_special_anim = "3_trident_special"
	has_special = true
	special_cost = 2

func special_attack() -> Dictionary:
	var dict : Dictionary = super()
	weapon_effects.position = player.position + Vector2(0,20)
	weapon_effects.z_index = player.z_index - 1
	return dict
	
func _on_player_anim_finished(anim : String) -> void:
	super(anim)
	animation_player.play("RESET")
	
func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if using_special:
		animation_player.play("shockwave")
	else:
		animation_player.play("stab")

func _on_player_special_impact() -> void:
	if !active:
		return
	for enemy : Enemy in enemies:
		enemy.damage(3)
