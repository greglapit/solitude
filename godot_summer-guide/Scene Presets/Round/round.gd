extends Node

var player_cards : Array[Card]
var max_cards : int = 4
var first_card_pos = Vector2(100,152)

@onready var console_log : TextEdit = find_child("ConsoleLog")
@onready var sharpen_button : Button = find_child("Sharpen")
@onready var chip_button : Button = find_child("Chip")
@onready var draw_button : Button = find_child("Draw")

# Custom Methods

func signal_setup():
	sharpen_button.button_up.connect(_on_sharpen_button_up)
	chip_button.button_up.connect(_on_chip_button_up)
	draw_button.button_up.connect(_on_draw_button_up)

func _on_sharpen_button_up():
	var card = find_child("Card")
	card.select()

func _on_chip_button_up():
	var card = find_child("Card")
	card.select()
	
func _on_draw_button_up():
	if len(player_cards) >= max_cards:
		console_log.display_text("Max cards")
		return
	var card : Card = Card.new_random_card(range(1,5), Card.Suits.DIAMOND)
	card.name = "Card" + str(len(player_cards))
	card.position = Vector2(first_card_pos.x + 35 * len(player_cards), first_card_pos.y)
	
	# Store card nodes and connect signals for mouse inputs
	player_cards.append(card)
	add_child(card)
	
	var card_area2d : Area2D = card.find_child("Area2D")
	card_area2d.mouse_entered.connect(_on_area2d_input)

# Built In

func _ready() -> void:
	signal_setup()
	
	
# Signals

func _on_area2d_input():
	print("test")
	
