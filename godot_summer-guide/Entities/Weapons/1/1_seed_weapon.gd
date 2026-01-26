extends Weapon

var seeded_enemy : Enemy
var damage_amt : int
@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_seed_weapon"
	display_name = "SeedStone"
	second_name = "Filler filler filler"
	if mini_equipped:
		description = "-Special: Seed %d\n-Convert remaining durability into a seed. Plant in enemy. Drain at end of turn\n-Cost:1" % [mini_equipped.durability]
	else:
		description = "-Special: Seed (5)\n-Convert remaining durability into a seed. Plant in enemy. Drain at end of turn\n-Cost:1"
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
	using_special = true
	player.play(player_special_anim)
	return {}

func drain() -> void:
	if !seeded_enemy:
		return
	pause.emit(self)
	damage_amt = min(seeded_enemy.rank, damage_amt)
	animation_player2.play("seeded_activate")
	await animation_player2.animation_finished
	animation_player2.play("RESET")
	seeded_enemy.damage(damage_amt)
	combat_data["hp_delta"] = damage_amt
	hp_update.emit(combat_data["hp_delta"])
	resume.emit(self)
	return
	

func post_combat() -> void:
	drain()
	
	
func has_valid_target(_enemies : Array) -> bool:
	if enemies[0] == seeded_enemy:
		return false
	return true

func _process(_delta: float) -> void:
	if seeded_enemy:
		weapon_effects2.position = seeded_enemy.collision_shape.global_position
		weapon_effects2.z_index = seeded_enemy.z_index + 1
		weapon_effects2.scale = seeded_enemy.collision_shape.scale

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
	
func _on_player_special_impact() -> void:
	if !active:
		return
	if using_special:
		seeded_enemy = enemies[0]
		seeded_enemy.play("shake")
		await seeded_enemy.animation_player.animation_finished
		animation_player2.play("seeded")
		damage_amt = mini_equipped.durability
		mini_equipped.damage(damage_amt)
		mini_equipped.used = true
		weapon_used.emit(self)
	using_special = false
