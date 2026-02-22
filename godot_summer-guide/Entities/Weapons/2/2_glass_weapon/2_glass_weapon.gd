extends Weapon

var damage_amt : int = 1
var bleed_duration : int = 2
var bleeding_enemies : Dictionary

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

func equip() -> void:
	super()
	description = "-Special: Lacerate\n-Bleed enemy for %d turns\n-Cost: 1" % [bleed_duration]

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

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")
