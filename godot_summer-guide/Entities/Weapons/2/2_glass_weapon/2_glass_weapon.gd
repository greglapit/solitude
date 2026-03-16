extends Weapon

var damage_amt : int = 1
var bleeding_enemies : Dictionary				## Enemy : Bleed_amt
var save_dict : Dictionary						## Enemy.name : bleed_amt

@onready var bleed_duration : int = weap_data.int1
@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

func initialize() -> void:
	super()
	
	bleeding_enemies.clear()
	# Saved in JSON as string, return bleeding_enemies with nodes as keys
	for enemy_name : String in save_dict.keys():
		var enemy : Enemy = get_node("/root/SceneHandler/Battle/" + enemy_name)
		bleeding_enemies[enemy] = save_dict[enemy_name]
		enemy.display_bleed(bleeding_enemies[enemy])

func set_bleed(target : Enemy, amt : int) -> void:
	bleeding_enemies[target] = amt
	target.display_bleed(bleeding_enemies[target])
	
	if bleeding_enemies[target] <= 0:
		bleeding_enemies.erase(target)
	
	save_dict.clear()
	# Save dict
	for enemy : Enemy in bleeding_enemies.keys():
		save_dict[enemy.name] = bleeding_enemies[enemy]

func bleed() -> void:
	pause.emit(self)
	for enemy : Enemy in bleeding_enemies.keys():
		enemy.damage(damage_amt)
		var bleed_amt : int = bleeding_enemies[enemy] - 1
		set_bleed(enemy, bleed_amt)
	resume.emit(self)

func post_combat() -> void:
	bleed()
	
func _on_player_special_impact() -> void:
	if !active:
		return
	var target : Enemy = enemies[0]
	var bleed_amt : int = bleed_duration
	bleed_amt += bleeding_enemies.get(target, 0)
	set_bleed(target, bleed_amt)
	target.damage(rank)
	target.display_bleed(bleeding_enemies[enemies[0]])

func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")

func _on_enemy_freed(_enemy : Enemy) -> void:
	bleeding_enemies.erase(_enemy)
