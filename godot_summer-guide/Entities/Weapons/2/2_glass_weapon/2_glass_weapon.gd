extends Weapon

var damage_amt : int = 1
var bleed_duration : int = 2
var bleeding_enemies : Dictionary

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

func assign_prop() -> void:
	rank = 2
	file_name = "2_glass_weapon"
	display_name = "Glass's Edge"
	second_name = "FILLER FILLER FILLER"
	description = "-Special: Lacerate\n-Bleed enemy for %d turns\n-Cost: 1" % [bleed_duration]
	display_texture = load("res://Entities/Weapons/%d/%s/%s.png" % [rank,file_name,file_name])
	player_idle_anim = "2_glass_idle"
	player_attack_anim = "2_glass_attack"
	player_defend_anim = "2_glass_defend"
	player_special_anim = "2_glass_special"
	has_special = true

func bleed() -> void:
	pause.emit(self)
	for enemy : Enemy in bleeding_enemies.keys():
		enemy.damage(damage_amt)
		bleeding_enemies[enemy] -= 1
		enemies[0].display_bleed(bleeding_enemies[enemy])
		if bleeding_enemies[enemy] <=0:
			bleeding_enemies.erase(enemy)
	resume.emit(self)

func post_combat() -> void:
	bleed()

func _on_player_special_impact() -> void:
	if !active:
		return
	bleeding_enemies[enemies[0]] = bleeding_enemies.get(enemies[0], 0) + bleed_duration
	enemies[0].damage(rank)
	enemies[0].display_bleed(bleeding_enemies[enemies[0]])
	mini_equipped.used = true
	mini_equipped.damage(combat_data["durability_delta"])

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")
