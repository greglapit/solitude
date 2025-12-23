class_name Card
extends Area2D

enum Suits {
	DIAMOND,
	HEART,
	SPADE,
	CLUB
}

var rank : int
var suit : Suits
const card_scn : PackedScene = preload("res://Common/UI/Armory/mini_card.tscn")

@onready var sprite2d : Sprite2D = $Sprite2D


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
	var suits = [suit1, suit2, suit3, suit4]
	var no_suit_constraint := suits.all(func(e): return e == -1)
	if no_suit_constraint:
		card.suit = randi() % 4 as Suits
	else:
		var suit_count = 0
		var suit_choices = []
		for _suit in suits:
			if _suit != -1:
				suit_choices.append(_suit)
				suit_count += 1
		card.suit = suit_choices[randi() % suit_count]
	# Temp
	card.rank = _range.pick_random()
	return card

func set_rank(_rank : int):
	rank = _rank
	
func set_suit(_suit : Suits):
	suit = _suit

# === Built In =================================================================

func _ready() -> void:
	sprite2d.frame = randi() % 4
	pass
	
func _input(_event: InputEvent) -> void:
	pass

# === Signals ==================================================================
