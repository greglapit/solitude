extends Weapon

var enemies_seeded_dict : Dictionary
var dmg : int
var seeded_scn : PackedScene = preload("res://Entities/Weapons/ArtWeaponEffects/seeded.tscn")

# === Custom Methods ===========================================================

func equip() -> void:
	super()
	if mini_equipped:
		description = "-Special: Seed (%d)\n-Cost: 1\n-Convert remaining durability (%d) into a seed and plant in enemy. Drains at end of combat." % [mini_equipped.durability, mini_equipped.durability]
	else:
		description = "-Special: Seed (5)\n-Convert remaining durability into a seed. Plant in enemy. Drain at end of turn\n-Cost:1"

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
		dmg = min(enemy.rank, dmg)
		enemy.damage(dmg)
		combat_data["hp_delta"] = dmg
		hp_update.emit(combat_data["hp_delta"])
		
	resume.emit(self)
	return
	

func post_combat() -> void:
	drain()
	

func _ready() -> void:
	print(GlobalsUtil.create_default_save_dict(self))

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
	var seeded_effect : AnimatedSprite2D = seeded_scn.instantiate()
	seeded_effect.add_to_group("persist")
	enemy.collision_shape.add_child(seeded_effect)
	enemies_seeded_dict[enemy] = seeded_effect
	enemy.play("shake")
	dmg = mini_equipped.durability
	mini_equipped.used = true
	mini_equipped.damage(dmg)
