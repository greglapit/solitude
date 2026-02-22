extends Weapon

var damage_amt : int = 2
var extra_damage_amount : int = 1
var marked_enemy : Enemy

@onready var weapon_effects2 : Sprite2D = $WeaponEffects2
@onready var animation_player2 : AnimationPlayer = $WeaponEffects2/AnimationPlayer

func equip() -> void:
	super()
	description = "-Special: Mark\n-Cost: 1\n-Attack and mark enemy. Attacking mark with %s deals %d. Otherwise, deal %d." % [display_name, damage_amt + extra_damage_amount, damage_amt]

func has_valid_spec_target(_enemies : Array) -> bool:
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
		target.damage(damage_amt + extra_damage_amount)
	else:
		target.damage(damage_amt)
	if target.is_dead:
		combat_fin.emit()
	resume.emit(self)
