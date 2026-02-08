@abstract class_name Weapon
extends Node2D

var rank : int = -1
var file_name : String
var display_name : String
var second_name : String
var description : String
var display_texture : Resource
var has_special : bool = false
var special_cost : int = 1
var using_special : bool = false

# Player/Enemy info
var player_idle_anim : String
var player_attack_anim : String
var player_defend_anim : String
var player_special_anim : String

var player : Node2D
var enemies : Array														## Enemies the player is in combat with. Position 0 is main target
var hp : float
var attacks : int
var mini_equipped : Card
@onready var animation_player : AnimationPlayer = $WeaponEffects/AnimationPlayer		## Weapon Effects animation player
@onready var weapon_effects : Sprite2D = $WeaponEffects

var active : bool = false 			## Whether weapon is active (equipped)
var reciprocal_attack : bool = false
var critting : bool = false			## Critting in current attack
var enemy_died : bool = false		## Enemy died from attack

var combat_data : Dictionary = {
	"hp_delta" = 0,
	"durability_delta" = 0,
	"attacks" = 0
	}


@warning_ignore("unused_signal")
signal crit
signal hp_update
@warning_ignore("unused_signal")
signal weapon_used(weapon : Weapon)			## Signals when weapon is put marked as used after attack
@warning_ignore("unused_signal")
signal combat_fin							## Signals when attack cycle is over
@warning_ignore("unused_signal")
signal pause(weapon : Weapon)				## Pause combat for combat effects to take place
@warning_ignore("unused_signal")
signal resume(weapon : Weapon)

# === Custom Methods ===========================================================
@abstract func assign_prop() -> void

func equip() -> void:
	player.play(player_idle_anim)

func unequip() -> void:
	return

func resolve_combat(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	player = _player
	mini_equipped = _mini_card
	hp = _hp
	attacks = _attacks
	enemies = _enemy_array
	critting = false
	reciprocal_attack = false
	enemy_died = false
	combat_data = {
	"hp_delta" = 0,
	"durability_delta" = -1,
	}
	
	# Visuals
	if active and enemies[0]:
		weapon_effects.position = enemies[0].position
		weapon_effects.z_index = enemies[0].z_index + 5
	
	# Combat order calculations
	# Player has no attacks left, enemy attacks
	if _attacks <= 0:
		combat_data= enemies[0].attack(self, combat_data)
		return combat_data
	
	# Player has attacks left
	if rank <= enemies[0].rank:
		if using_special:
			player.play(player_special_anim)
		else:
			player.play(player_attack_anim)
		return combat_data
	else:
		reciprocal_attack = true
		combat_data = enemies[0].attack(self, combat_data)
		return combat_data

func special_attack(_player : Node2D, _mini_card : Card, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	if !has_special:
		push_error("No special to be called")
		return {}
	using_special = true
	return resolve_combat(_player, _mini_card, _hp, _attacks, _enemy_array)
	
func post_combat() -> void:
	pass
	
func has_valid_spec_target(_enemies : Array) -> bool:
	if _enemies[0] and !_enemies[0].is_dead:
		return true
	return false
	
# === Built In =================================================================

func _ready() -> void:
	assign_prop()
	
func _input(_event: InputEvent) -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
# === Signals ==================================================================

func _on_player_anim_finished(anim : String) -> void:
	if !active or !anim.contains(str(rank)):
		return
	if !enemies[0] or enemies[0].is_dead:
		enemy_died = true
	else:
		enemy_died = false
	if anim.contains("attack") or anim.contains("special"):
		# Damage Weapon
		if !critting:
			mini_equipped.used = true
			mini_equipped.play("used")
			mini_equipped.damage(-combat_data["durability_delta"])
			
		# Attacked after enemy due to higher card rank
		if reciprocal_attack or enemy_died:
			combat_fin.emit()
			reciprocal_attack = false
			critting = false
			enemy_died = false
		# Player lower with higher rank card
		else:
			weapon_used.emit(self)
			
		using_special = false
		return
		
	if anim.contains("defend"):
		if !reciprocal_attack:
			combat_fin.emit()
		else:
			if using_special:
				player.play(player_special_anim)
			else:
				player.play(player_attack_anim)
		return
		

func _on_player_attack_impact() -> void:
	if !active:
		return
	# Lower rank weapon attacks faster
	if rank == enemies[0].rank:
		critting = true
		crit.emit()
	enemies[0].damage(rank)

func _on_player_special_impact() -> void:
	pass

func _on_player_weap_effect_start() -> void:
	pass
	
func _on_enemy_attack_impact() -> void:
	if !active:
		return
	player.play(player_defend_anim)
	hp_update.emit(combat_data["hp_delta"])
	

func _on_enemy_freed(_enemy : Enemy) -> void:
	pass
