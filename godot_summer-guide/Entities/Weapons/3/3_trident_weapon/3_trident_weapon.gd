extends Weapon

@onready var dmg : int = weap_data.int1

func _on_player_anim_finished(anim : String) -> void:
	super(anim)
	animation_player.play("RESET")
	
func _on_player_weap_effect_start() -> void:
	if !active:
		return
	if using_special:
		weapon_effects.position = player.position + Vector2(0,20)
		weapon_effects.z_index = player.z_index - 1
		animation_player.play("shockwave")
	else:
		animation_player.play("stab")

func _on_player_special_impact() -> void:
	if !active:
		return
	for enemy : Enemy in enemies:
		enemy.damage(3)
