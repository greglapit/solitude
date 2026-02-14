class_name Enemy
extends Area2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var card_sprite : Sprite2D = $CollisionShape2D/CardSprite
@onready var suit_sprite : Sprite2D = $CollisionShape2D/SuitSprite
@onready var label1 : Label = $CollisionShape2D/Label
@onready var label2 : Label = $CollisionShape2D/Label2
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var status_label : Label = $CollisionShape2D/Status/Label
@onready var status_animation_player : AnimationPlayer = $CollisionShape2D/Status/AnimationPlayer2

# Node References
var player : Node2D
const enemy_scn : PackedScene = preload("res://Entities/Enemies/base_enemy.tscn")

# Stats
var rank : int = -1:
	set(value):
		rank_update.emit(value)
		rank = value
var suit : Card.Suits = Card.Suits.HEART
var suit_art_path : String = "res://Entities/Enemies/Base/Art/"
var is_dead : bool = false

# Status Effects
var chained : bool = false		# Locklash
var webbed : bool = false		# Weaver
var prowled : bool = false		# Prowler

# Status Effect Logic. Updated in _process
var attack_disabled : bool = false
var slowed : bool = false

signal rank_update(new : int)
@warning_ignore("unused_signal")
signal attack_impact
signal attack_prevented(enemy : Enemy)
signal damaged(amt : int)
signal freed(enemy : Enemy)

# === Custom Methods ===========================================================
static func new_enemy(_suit : Card.Suits, _ranks : Array[int]) -> Enemy:
	var _rank : int = _ranks.pick_random()
	if _suit not in Card.Suits.values() or _rank not in range(1,14):
		print("Invalid enemy declaration")
		return
	var enemy : Enemy = enemy_scn.instantiate()
	enemy.suit = _suit
	enemy.rank = _rank
	return enemy

func update_labels() -> void:
	label1.text = Globals.ranks[rank]
	label2.text = Globals.ranks[rank]

## Damage the enemy
func damage(amt : int) -> int:
	rank  = max(rank-amt, 0)
	damaged.emit(amt)
	if rank <= 0:
		is_dead = true
		play("death")
	else:
		play("shake")
	update_labels()
	
	return amt

## Damage the player
func attack(_weapon : Weapon, _combat_data : Dictionary) -> Dictionary:
	var combat_data : Dictionary = _combat_data
	
	if attack_disabled:
		attack_prevented.emit(self)
		return combat_data
	
	if rank <= 0:
		combat_data["hp_delta"] = rank
		return combat_data
	play("attack")
	combat_data["hp_delta"] = -rank
	return combat_data

func play(anim : String = "RESET") -> void:
	animation_player.stop()
	animation_player.play(anim)

func display_bleed(duration : int) -> void:
	status_label.text = str(duration)
	if duration > 0:
		status_animation_player.play("bleeding")
	else:
		status_animation_player.play("RESET")

@warning_ignore("unused_parameter")
func emit_freed(card : Enemy = self) -> void:
	freed.emit(self)
	
# === Built In =================================================================

func _ready() -> void:
	var suit_name : String = str(Card.Suits.keys()[suit]).to_lower() + "s" + ".png"
	suit_sprite.texture = load(suit_art_path + suit_name)
	card_sprite.frame = randi() % 4
	suit_sprite.frame = randi() % 4
	
	update_labels()
	play("spawn")
	
func _input(_event: InputEvent) -> void:
	pass

func _process(_delta: float) -> void:
	if chained: # add other attack disabling HERE
		attack_disabled = true
	else:
		attack_disabled = false
		
	if webbed or prowled: # add other slows HERE
		slowed = true
	else:
		slowed = false

# === Signals ==================================================================


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_player.play("idle")
