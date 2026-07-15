extends Weapon

@onready var damage_amt : int = weap_data.int1
@onready var extra_damage_amount : int = weap_data.int2
@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

var marked_enemy : Enemy

func has_valid_spec_target(_enemies : Array) -> bool:
	if _enemies.is_empty():
		return false
	if _enemies[0] == marked_enemy:
		return false
	return true
	
	
func _process(_delta: float) -> void:
	super(_delta)
	if marked_enemy:
		weapon_effects2.global_position = marked_enemy.collision_shape.global_position
		weapon_effects2.z_index = marked_enemy.z_index + 1


func _on_player_special_impact() -> void:
	if !active:
		return
	marked_enemy = enemies[0]
	marked_enemy.damage(rank)
	if marked_enemy.is_dead:
		return
	marked_enemy.damaged.connect(_on_enemy_damaged.bind(marked_enemy))
	animation_player2.play("mark")
	
	
func _on_player_weap_effect_start() -> void:
	if !active:
		return
	animation_player.play("double_slash")

func _on_enemy_damaged(_amt : int, enemy : Enemy) -> void:
	pause.emit(self)
	await enemy.animation_player.animation_finished
	if marked_enemy and (enemy != marked_enemy or marked_enemy.is_dead):
		animation_player2.play("RESET")
		resume.emit(self)
		return
	var target : Enemy = marked_enemy
	marked_enemy.damaged.disconnect(_on_enemy_damaged)
	animation_player2.play("mark_expend")
	await animation_player2.animation_finished
	marked_enemy = null
	
	if mini_equipped.rank == 2:
		target.damage(extra_damage_amount)
	else:
		target.damage(damage_amt)
	if target.is_dead:
		combat_fin.emit()
	resume.emit(self)
