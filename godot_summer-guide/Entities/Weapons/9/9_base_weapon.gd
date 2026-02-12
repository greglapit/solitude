extends Weapon

@onready var weapons_effects2 : Sprite2D = $WeaponEffects2

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

func resolve_combat(_player : Node2D,_mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	combat_data = super(_player,_mini_card, _hp, _attacks, _enemy_array)
	weapon_effects.z_index = _enemy_array[0].z_index - 1
	weapons_effects2.position = weapon_effects.position
	weapons_effects2.z_index = _enemy_array[0].z_index + 1
	return combat_data

func _on_player_weap_effect_start() -> void:
	animation_player.play("ground_crack")
