extends Weapon

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2

func _on_player_weap_effect_start() -> void:
	var target : Enemy = enemies[0]
	weapon_effects2.global_position = target.global_position
	weapon_effects.z_index = target.z_index - 1
	animation_player.play("ground_crack")
