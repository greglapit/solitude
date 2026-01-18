class_name Enemy
extends Area2D

@onready var card_sprite : Sprite2D = $CollisionShape2D/CardSprite
@onready var suit_sprite : Sprite2D = $CollisionShape2D/SuitSprite
@onready var label1 : Label = $CollisionShape2D/Label
@onready var label2 : Label = $CollisionShape2D/Label2
@onready var animation_player : AnimationPlayer = $AnimationPlayer

const enemy_scn : PackedScene = preload("res://Entities/Enemies/base_enemy.tscn")

var rank : int = -1
var ranks : Array = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var suit : Card.Suits = Card.Suits.HEART
var suit_art_path : String = "res://Entities/Enemies/Base/Art/"

var player : Node2D

@warning_ignore("unused_signal")
signal attack_impact
signal freed(enemy : Enemy)

# === Custom Methods ===========================================================
static func new_enemy(_suit : Card.Suits, _rank : int) -> Enemy:
	if _suit not in Card.Suits.values() or _rank not in range(1,14):
		print("Invalid enemy declaration")
		return
	var enemy : Enemy = enemy_scn.instantiate()
	enemy.suit = _suit
	enemy.rank = _rank
	return enemy

func update_labels() -> void:
	label1.text = ranks[rank]
	label2.text = ranks[rank]

## Damage the enemy
func damage(amt : int) -> Callable:
	rank  = max(rank-amt, 0)
	if rank <= 0:
		play("death")
	else:
		play("shake")
	update_labels()
	
	return func() -> void: return

## Damage the player
func attack(_weapon : Weapon, _combat_data : Dictionary) -> Dictionary:
	var combat_data : Dictionary = _combat_data
	
	if rank <= 0:
		combat_data["hp_lost"] = rank
		return combat_data
	animation_player.play("attack")
	combat_data["hp_lost"] = rank
	return combat_data

func play(anim : String = "RESET") -> void:
	animation_player.play(anim)

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

# === Signals ==================================================================


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	play("idle")
