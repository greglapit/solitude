@abstract class_name Weapon
extends Node2D

@onready var animation_player : AnimationPlayer = $WeaponEffects/AnimationPlayer		## Weapon Effects animation player
@onready var weapon_effects : Sprite2D = $WeaponEffects

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

# Variables from battle_scn
var player : Node2D
var enemies : Array					## Enemies the player is in combat with. Position 0 is main target
var hp : float
var crit_stored : int 
var attacks : int
var mini_equipped : Card
var mini_cards : Array
var turn_order_flipped : bool:
	set(value):
		if value:
			order = -1
		else:
			order = 1
		turn_order_flipped = value
var order : int = 1
var battle_node : Node = get_parent()


var active : bool = false 			## Whether weapon is active (equipped)
var reciprocal_attack : bool = false
var critting : bool = false			## Critting in current attack
var enemy_died : bool = false		## Enemy died from attack

var combat_data : Dictionary = {
	"hp_delta" = 0,
	"durability_delta" = 0,
	"attacks" = 0
	}

# Signals
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
	update_node_refs()
	player.play(player_idle_anim)

func unequip() -> void:
	return

func update_node_refs() -> void:
	battle_node = get_parent()
	player = battle_node.player
	if is_instance_valid(battle_node.mini_equipped):
		mini_equipped = battle_node.mini_equipped
	mini_cards = get_tree().get_nodes_in_group("mini_cards")
	hp = battle_node.hp
	crit_stored = battle_node.crit_stored
	attacks = battle_node.attacks
	enemies = get_tree().get_nodes_in_group("enemies")
	turn_order_flipped = battle_node.turn_order_flipped
	
	# Visuals
	if active and !enemies.is_empty() and enemies[0]:
		weapon_effects.global_position = enemies[0].global_position
		weapon_effects.z_index = enemies[0].z_index + 5

func resolve_combat() -> Dictionary:
	update_node_refs()
	critting = false
	reciprocal_attack = false
	enemy_died = false
	combat_data = {
	"hp_delta" = 0,
	"durability_delta" = -1,
	}
	
	#===== Combat order calculations
	# Player has no attacks left, enemy attacks
	if attacks <= 0:
		combat_data= enemies[0].attack(self, combat_data)
		return combat_data
	
	# Player has attacks left
	if rank * order <= enemies[0].rank * order or enemies[0].slowed:
		if using_special:
			player.play(player_special_anim)
		else:
			player.play(player_attack_anim)
		return combat_data
	else:
		reciprocal_attack = true
		combat_data = enemies[0].attack(self, combat_data)
		return combat_data

func special_attack() -> Dictionary:
	update_node_refs()
	if !has_special:
		push_error("No special to be called")
		return {}
	using_special = true
	return resolve_combat()
	
func post_combat() -> void:
	pass
	
func has_valid_spec_target(_enemies : Array) -> bool:
	if _enemies.is_empty():
		return false
	if _enemies[0] and !_enemies[0].is_dead:
		return true
	return false

func enemy_attack() -> void:
	if enemies.is_empty():
		return
	var target : Enemy = enemies[0]
	target.attack(self,combat_data)

# === Built In =================================================================

func _ready() -> void:
	combat_data["durability_delta"] = -1
	assign_prop()
	
func _input(_event: InputEvent) -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
# === Signals ==================================================================

func _on_player_anim_finished(anim : String) -> void:
	if !active: # or !anim.contains(str(rank)):
		return
	update_node_refs()
	if enemies.is_empty() or enemies[0].is_dead:
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
			#reciprocal_attack = false
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
	
func _on_enemy_spawned(_enemy : Enemy) -> void:
	pass
	
func _on_enemy_attack_impact(_enemy : Enemy) -> void:
	if !active:
		return
	player.play(player_defend_anim)
	hp_update.emit(combat_data["hp_delta"])

func _on_enemy_attack_prevented(_enemy : Enemy) -> void:
	pass

func _on_enemy_rank_update(_new : int, _enemy : Enemy) -> void:
	pass

func _on_enemy_freed(_enemy : Enemy) -> void:
	pass
