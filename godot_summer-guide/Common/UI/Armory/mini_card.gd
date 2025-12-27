class_name Card
extends Area2D

# Logic
enum Suits {
	DIAMOND,
	HEART,
	SPADE,
	CLUB
}
var rank : int = 0
var suit : Suits = Suits.DIAMOND
var ranks : Array = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var selected : bool = false
var durability : int = 5

# Visuals
const card_scn : PackedScene = preload("res://Common/UI/Armory/mini_card.tscn")
var red : Color = Color.html("#b33831")
var black : Color = Color.html("#2e222f")

signal free

@onready var sprite2d : Sprite2D = $CollisionShape2D/Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var label1 : Label = $CollisionShape2D/Labels/Label
@onready var label2 : Label = $CollisionShape2D/Labels/Label2


# === Custom Methods ===========================================================
static func new_card(_suit : Suits, _rank : int) -> Card:
	if _suit not in Suits.values() or _rank not in range(1,14):
		print("Invalid card declaration")
		return
	var card : Card = card_scn.instantiate()
	card.suit = _suit
	card.rank = _rank
	return card

## Returns random card with optional range for rank and suit
static func new_random_card(_range : Array = range(1,14), suit1 : int = -1, suit2 : int = -1, suit3 : int = -1, suit4 : int = -1) -> Card:
	
	var card : Card = card_scn.instantiate()
	var suits : Array[int] = [suit1, suit2, suit3, suit4]
	
	var no_suit_constraint : bool = suits.all(func(e : int) -> bool: return e == -1)
	if no_suit_constraint:
		card.suit = randi() % 4 as Suits
	else:
		var suit_count : int= 0
		var suit_choices : Array[int]= []
		for _suit : int in suits:
			if _suit != -1:
				suit_choices.append(_suit)
				suit_count += 1
		card.suit = suit_choices[randi() % suit_count] as Suits
	
	card.rank = _range.pick_random()
	return card

func set_rank(_rank : int) -> void:
	rank = _rank
	
func set_suit(_suit : Suits) -> void:
	suit = _suit

func select() -> void:
	selected = true
	animation_player.play("selected")
	return
	
func deselect() -> void:
	selected = false
	if animation_player.current_animation == "selected":		# Prevents overwriting of animation
		animation_player.play("RESET")							# if player stops hovering
	return

func damage(amount : int = 1) -> void:
	durability -= amount
	if durability <= 0:
		free.emit(self)
		animation_player.play("break")
	
func chip(amount : int = 1) -> void:
	if durability <= 1 or \
	not Globals.available_ranks.has(rank - amount):
		animation_player.play("shake")
		return
		
	damage()
	rank -= amount
	update_visuals()
	
func sharpen(amount : int = 1) -> void:
	if durability <= 1 or \
	not Globals.available_ranks.has(rank + amount):
		animation_player.play("shake")
		return
	damage()
	rank += amount
	update_visuals()
	
func update_visuals() -> void:
	# Frames for card variant are stored every 4. Obscure math to account for this animation
	var frame : int = (sprite2d.frame) % 4
	sprite2d.frame = frame + (4 * (5 - durability))
	label1.text = ranks[rank]
	label2.text = ranks[rank]

func play(anim : String, reverse : bool = false) -> void:
	if reverse:
		animation_player.play_backwards(anim)
	else:
		animation_player.play(anim)

# === Built In =================================================================

func _ready() -> void:
	# Assigns random edge texture
	sprite2d.frame = randi() % 4
	animation_player.play("spawn")
	update_visuals()
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET":
		animation_player.play("RESET")
