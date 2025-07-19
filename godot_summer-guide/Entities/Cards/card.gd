class_name Card
extends Node2D

const card_scene : PackedScene = preload("res://Entities/Cards/Scenes/card.tscn")
var red = Color.html("#b33831")
var black = Color.html("#2e222f")
var ranks = ["0","A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

@onready var sprite2d = $Sprite2D
@onready var upper_left_label = $Control/UpperLeftLabel
@onready var lower_right_label = $Control/LowerRightLabel

enum Suits {
	DIAMOND,
	HEART,
	SPADE,
	CLUB
}

var suit : Suits
var rank : int

static func new_card(suit : Suits, rank : int) -> Card:
	if suit not in Suits.values() or rank not in range(1,14):
		print("Invalid card declaration")
		return
	var new_card : Card = card_scene.instantiate()
	new_card.suit = suit
	new_card.rank = rank
	return new_card

## Returns random card with optional range for rank and suit
static func random_card(range : Array = range(1,14), suit1 : Suits = -1, suit2 : Suits = -1, suit3 : Suits = -1, suit4 : Suits = -1) -> Card:
	var new_card : Card = card_scene.instantiate()
	var suits = [suit1, suit2, suit3, suit4]
	if suits.all(func(e): return e == -1):
		new_card.suit = randi() % 4
	else:
		var suit_count = 0
		var suit_choices = []
		for suit in suits:
			if suit != -1:
				suit_choices.append(suit)
				suit_count += 1
		new_card.suit = suit_choices[randi() % suit_count]
	# Temp
	new_card.rank = randi() % 13 + 1
	return new_card
	

func find_card_texture(suit : Suits) -> String:
	var file_path = "res://Entities/Cards/Art/bare_" + str(Suits.find_key(suit).to_lower()) + ".png"
	return file_path

func update_card_visuals():
	
	# Texture
	var texture = find_card_texture(suit)
	sprite2d.texture = load(texture)
	
	# Label Colors
	var card_num_res = "res://Entities/Cards/Resources/card_numbers.tres"
	upper_left_label.label_settings = load(card_num_res).duplicate()
	lower_right_label.label_settings = upper_left_label.label_settings
	if suit ==  0 or suit == 1:
		upper_left_label.label_settings.font_color = red
	else:
		upper_left_label.label_settings.font_color = black
	
	# Rank
	var card_text : String = ranks[rank]
	upper_left_label.text = card_text
	lower_right_label.text = card_text

func _ready() -> void:
	update_card_visuals()
