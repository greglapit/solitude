extends Weapon

var damage_amt : int = 1
var bleeding_enemies : Dictionary

@onready var bleed_duration : int = weap_data.int1
@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

#region
# Obsolete. No longer allowing saving during battle
func save() -> Dictionary:
	var data : Dictionary = super()
	GlobalsUtil.rekey_objects_to_names(bleeding_enemies)
	data["bleeding_enemies"] = bleeding_enemies
	return data

func initialize() -> void:
	super()
	for enemy : Enemy in bleeding_enemies.keys():
		enemy.display_bleed(bleeding_enemies[enemy])
#endregion

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
	var target : Enemy = enemies[0]
	bleeding_enemies[target] = bleeding_enemies.get(target, 0) + bleed_duration
	target.damage(rank)
	target.display_bleed(bleeding_enemies[enemies[0]])

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")

func _on_enemy_freed(_enemy : Enemy) -> void:
	bleeding_enemies.erase(_enemy)
