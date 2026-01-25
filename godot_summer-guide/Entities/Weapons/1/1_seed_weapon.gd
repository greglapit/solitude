extends Weapon

var seeded_enemy : Enemy
var damage_amt : int
@onready var weapons_effects2 : Sprite2D = $WeaponEffects2

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_seed_weapon"
	display_name = "SeedStone"
	second_name = "Filler filler filler"
	description = "-Special: Plant seed in enemy\n-Drains amt at end of turn, based on durability\n -Cost:1"
	display_texture = load("res://Common/UI/WeaponDisplay/Art/Weapons/1/1_seed_weapon.png")
	player_idle_anim = "1_seed_idle"
	player_attack_anim = "1_seed_attack"
	player_defend_anim = "1_seed_defend"
	player_special_anim = "1_seed_special"
	has_special = true
	special_cost = 1

func special_attack(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	enemies = _enemy_array
	mini_equipped = _mini_card
	weapons_effects2.position = enemies[0].position
	weapons_effects2.z_index = enemies[0].z_index + 1
	using_special = true
	player.play(player_special_anim)
	return {}

func drain() -> Signal:
	if !seeded_enemy:
		return get_tree().create_timer(.1).timeout
	damage_amt = min(seeded_enemy.rank, damage_amt)
	animation_player.play("seeded_activate")
	await animation_player.animation_finished
	animation_player.play("RESET")
	seeded_enemy.damage(damage_amt)
	combat_data["hp_delta"] = damage_amt
	hp_update.emit(combat_data["hp_delta"])
	return animation_player.animation_finished
	
	
func post_combat() -> Signal:
	await drain()
	return get_tree().create_timer(.1).timeout
	

func _on_player_special_impact() -> void:
	if !active:
		return
	if using_special:
		seeded_enemy = enemies[0]
		seeded_enemy.play("shake")
		await seeded_enemy.animation_player.animation_finished
		animation_player.play("seeded")
		damage_amt = mini_equipped.durability
		mini_equipped.damage(damage_amt)
		mini_equipped.used = true
		weapon_used.emit(self)
	using_special = false
