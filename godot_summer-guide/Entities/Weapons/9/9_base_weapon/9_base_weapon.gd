extends Weapon

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2

func assign_prop() -> void:
	rank = 9
	file_name = "9_base_weapon"
	display_name = "SI 09: STAFF"
	second_name = "Diamond Standard Issue"
	description = "-Standard Issue Staff"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "9_base_idle"
	player_attack_anim = "9_base_attack"
	player_defend_anim = "9_base_defend"

func _on_player_weap_effect_start() -> void:
	var target : Enemy = enemies[0]
	weapon_effects2.global_position = target.global_position
	weapon_effects.z_index = target.z_index - 1
	animation_player.play("ground_crack")
