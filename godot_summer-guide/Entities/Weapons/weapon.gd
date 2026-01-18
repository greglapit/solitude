@abstract class_name Weapon
extends Node2D

var rank : int = -1
var file_name : String
var display_name : String
var second_name : String
var description : String
var display_texture : Resource
var has_special : bool = false

# Player/Enemy info
var player_idle_anim : String
var player_attack_anim : String
var player_defend_anim : String

var player : Node2D
var enemies : Array														## Enemies the player is in combat with. Position 0 is main target
@onready var animation_player : AnimationPlayer = $AnimationPlayer		## Weapon Effects animation player
@onready var weapon_effects : Sprite2D = $WeaponEffects

var active : bool = false 			## Whether weapon is active (equipped)
var reciprocal_attack : bool = false
var critting : bool = false

var combat_data : Dictionary = {
	"hp_lost" = 0,
	"durability_lost" = 1,
	"attacks" = 0
	}


@warning_ignore("unused_signal")
signal crit
signal hp_update
@warning_ignore("unused_signal")
signal weapon_used							## Signals when weapon is put marked as used after attack
@warning_ignore("unused_signal")
signal combat_fin							## Signals when attack cycle is over

# === Custom Methods ===========================================================
@abstract func assign_prop() -> void

func equip() -> void:
	player.play(player_idle_anim)

func resolve_combat(_player : Node2D, _hp : float, _attacks : int, _enemy_array : Array) -> Dictionary:
	player = _player
	enemies = _enemy_array
	critting = false
	reciprocal_attack = false
	combat_data = {
	"hp_lost" = 0,
	"durability_lost" = 0,
	"attacks" = _attacks
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
	
	combat_data["durability_lost"] = 1
	# Player has attacks left
	if rank <= enemies[0].rank:
		player.play(player_attack_anim)
		return combat_data
	else:
		reciprocal_attack = true
		combat_data= enemies[0].attack(self, combat_data)
		return combat_data

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
	if anim.contains("attack"):
		
		# Attacked after enemy due to higher card rank
		if critting or reciprocal_attack:
			combat_fin.emit()
			reciprocal_attack = false
		# Player lower with higher rank card
		else:
			weapon_used.emit(self)
		#equip()
	if anim.contains("defend"):
		if !reciprocal_attack:
			player.play(player_idle_anim)
			combat_fin.emit()
		else:
			player.play(player_attack_anim)
			reciprocal_attack = false

func _on_player_attack_impact() -> void:
	if !active:
		return
	# Lower rank weapon attacks faster
	if rank == enemies[0].rank:
		critting = true
		crit.emit()
	enemies[0].damage(rank)

@abstract func _on_player_weap_effect_start() -> void
	
func _on_enemy_attack_impact() -> void:
	if !active:
		return
	player.play(player_defend_anim)
	hp_update.emit(combat_data["hp_lost"])
	

func _on_enemy_freed(_enemy : Enemy) -> void:
	combat_fin.emit()
