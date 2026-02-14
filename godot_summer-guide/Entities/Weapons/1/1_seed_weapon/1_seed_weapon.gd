extends Weapon

var enemies_seeded_dict : Dictionary
var damage_amt : int
var seeded_scn : PackedScene

# === Custom Methods ===========================================================

func assign_prop() -> void:
	rank = 1
	file_name = "1_seed_weapon"
	display_name = "SeedStone"
	second_name = "Filler filler filler"
	if mini_equipped:
		description = "-Special: Seed\n-Cost: 1\n-Convert remaining durability (%d) into a seed and plant in enemy. Drains at end of combat." % [mini_equipped.durability]
	else:
		description = "-Special: Seed (5)\n-Convert remaining durability into a seed. Plant in enemy. Drain at end of turn\n-Cost:1"
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "1_seed_idle"
	player_attack_anim = "1_seed_attack"
	player_defend_anim = "1_seed_defend"
	player_special_anim = "1_seed_special"
	has_special = true
	special_cost = 1

func drain() -> void:
	if enemies_seeded_dict.is_empty():
		return
	pause.emit(self)
	for enemy : Enemy in enemies_seeded_dict.keys().duplicate():
		var seeded_effect : AnimatedSprite2D = enemies_seeded_dict[enemy]
		seeded_effect.play("expend")
		await seeded_effect.animation_finished
		seeded_effect.queue_free()
		enemies_seeded_dict.erase(enemy)
		
		# Damage + Heal
		damage_amt = min(enemy.rank, damage_amt)
		enemy.damage(damage_amt)
		combat_data["hp_delta"] = damage_amt
		hp_update.emit(combat_data["hp_delta"])
		
	resume.emit(self)
	return
	

func post_combat() -> void:
	drain()
	

func _ready() -> void:
	super()
	seeded_scn = load("res://Entities/Weapons/ArtWeaponEffects/seeded.tscn")

func has_valid_spec_target(_enemies : Array) -> bool:
	if enemies[0] in enemies_seeded_dict.keys():
		return false
	return true

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("siphon")
	
func _on_player_special_impact() -> void:
	if !active:
		return
	
	var enemy : Enemy = enemies[0]
	var seeded_effect : AnimatedSprite2D =seeded_scn.instantiate()
	enemy.collision_shape.add_child(seeded_effect)
	enemies_seeded_dict[enemy] = seeded_effect
	enemy.play("shake")
	damage_amt = mini_equipped.durability
	mini_equipped.used = true
	mini_equipped.damage(damage_amt)
